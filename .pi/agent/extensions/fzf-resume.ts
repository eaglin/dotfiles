/**
 * fzf Resume-All Extension
 *
 * Adds /fra command + Ctrl+Shift+R shortcut to pick a session from ANY
 * project via fzf and resume it.
 *
 * Keybindings inside fzf:
 *   Enter      → resume in the current tab
 *   Ctrl+T     → open in a new herdr tab
 *   Ctrl+D     → enter delete mode (Enter deletes selected, Ctrl+D deletes all)
 *   Esc        → cancel
 *
 * Requires: fzf installed and available on $PATH.
 * Optional: herdr installed and available on $PATH for new-tab support.
 *
 * The command uses ExtensionCommandContext (has switchSession).
 * The shortcut dispatches /fra directly, so the picker opens immediately.
 * (Shortcuts only get ExtensionContext, so session switching remains in the
 *  command handler.)
 */

import { spawnSync } from "node:child_process";
import { unlinkSync } from "node:fs";
import {
  SessionManager,
  type ExtensionAPI,
  type ExtensionCommandContext,
  type ExtensionContext,
  type SessionInfo,
} from "@earendil-works/pi-coding-agent";

function formatRelative(date: Date): string {
  const diff = Date.now() - date.getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return "just now";
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  const days = Math.floor(hrs / 24);
  if (days < 30) return `${days}d ago`;
  const months = Math.floor(days / 30);
  if (months < 12) return `${months}mo ago`;
  return `${Math.floor(months / 12)}y ago`;
}

function shortCwd(cwd: string): string {
  if (!cwd) return "~";
  return cwd.replace(process.env.HOME ?? "", "~");
}

function buildFzfLines(sessions: SessionInfo[]): string[] {
  return sessions
    .sort((a, b) => b.modified.getTime() - a.modified.getTime())
    .map((s) => {
      const when = formatRelative(s.modified);
      const label = (s.name || s.firstMessage || "(empty)").replace(/\t/g, " ").slice(0, 100);
      const cwd = shortCwd(s.cwd);
      const msgs = `${s.messageCount}m`;
      return [when, msgs, label, cwd, s.path].join("\t");
    });
}

function parseFzfOutput(line: string): string | null {
  const fields = line.split("\t");
  return fields[fields.length - 1]?.trim() || null;
}

/** Quiet spawnSync: all stdio piped, nothing leaks to the terminal. */
function herdr(args: string[]): string {
  const result = spawnSync("herdr", args, {
    stdio: ["pipe", "pipe", "pipe"],
    encoding: "utf-8",
    timeout: 10000,
  });
  return result.stdout ?? "";
}

/**
 * Open a session in a new herdr tab.
 *
 * Creates a new herdr tab with the session's cwd, then sends
 * `pi --session <path>` to the tab's root pane.
 *
 * Returns true on success, false on any error.
 */
function openInNewHerdrTab(session: SessionInfo): boolean {
  const label = (session.name || session.firstMessage || "pi session")
    .replace(/["\\\t\n]/g, " ")
    .slice(0, 50);
  const cwd = session.cwd || process.cwd();

  // Create a new tab with the session's working directory
  const createOut = herdr([
    "tab", "create",
    "--cwd", cwd,
    "--label", label,
    "--focus",
  ]);

  if (!createOut.trim()) return false;

  try {
    const parsed = JSON.parse(createOut.trim());
    const paneId: string | undefined = parsed?.result?.root_pane?.pane_id;
    if (!paneId) return false;

    // Send `pi --session <path>` to the new pane via send-text + send-keys.
    // We can't use `herdr pane run` because herdr intercepts --session as
    // its own CLI flag.
    const cmd = `pi --session ${session.path}`;

    // Wait for the shell prompt to appear before sending the command.
    spawnSync("herdr", [
      "pane", "wait-output",
      "--match", "%",
      "--timeout", "3000",
      paneId,
    ], {
      stdio: ["pipe", "pipe", "pipe"],
      encoding: "utf-8",
      timeout: 10000,
    });

    // Small extra delay to ensure the shell is fully ready
    spawnSync("sleep", ["0.3"]);

    herdr(["pane", "send-text", paneId, cmd]);
    herdr(["pane", "send-keys", paneId, "Enter"]);

    return true;
  } catch {
    return false;
  }
}

/** Result from the fzf picker. */
type FzfPickResult =
  | { action: "resume"; path: string }
  | { action: "new-tab"; path: string }
  | { action: "delete"; path: string }
  | { action: "delete-all" }
  | { action: "cancel" };

/**
 * Run fzf picker with keybindings:
 *   Enter   → resume in current tab
 *   Ctrl+T  → open in new herdr tab
 *   Ctrl+D  → enter delete confirmation mode
 */
async function runFzfPicker(
  ctx: ExtensionCommandContext | ExtensionContext,
  sessions: SessionInfo[],
): Promise<FzfPickResult> {
  if (ctx.mode !== "tui") return { action: "cancel" };
  if (sessions.length === 0) return { action: "cancel" };

  const lines = buildFzfLines(sessions);
  const header = "When\tMsgs\tName / First message\tProject  (Ctrl+T new tab · Ctrl+D delete)";

  return ctx.ui.custom<FzfPickResult>((tui, _theme, _kb, done) => {
    tui.stop();

    // ── First pass: normal picker (popup at bottom, no full-screen clear) ──
    let result = spawnSync("fzf", [
      "--ansi",
      `--delimiter=\t`,
      "--with-nth=1,2,3,4",
      `--header=${header}`,
      "--header-first",
      "--reverse",
      "--info=inline",
      "--prompt=resume> ",
      "--no-sort",
      "--expect=ctrl-d,ctrl-t",
      "--margin=25%,30%",
      "--border=rounded",
    ], {
      stdio: ["pipe", "pipe", "inherit"],
      input: lines.join("\n"),
      encoding: "utf-8",
    });

    if (result.status !== 0 || !result.stdout?.trim()) {
      tui.start();
      tui.requestRender(true);
      done({ action: "cancel" });
      return { render: () => [], invalidate: () => {} };
    }

    // --expect puts the key on the first line, selected item on the rest.
    // DO NOT use .trim() on the full stdout: when Enter is pressed the key
    // line is empty (just "\n"), and trim() would remove it, shifting every
    // field and losing the selected path.
    const out1 = result.stdout.split("\n");
    if (out1.length > 0 && out1[out1.length - 1] === "") out1.pop(); // trailing newline
    const key1 = out1[0] ?? "";
    const path1 = parseFzfOutput(out1.slice(1).join("\n"));

    if (key1 === "ctrl-d") {
      // ── Second pass: delete mode ──
      //   Enter   → delete the selected session
      //   Ctrl+D  → delete ALL sessions
      //   Esc     → cancel
      const deleteHeader = "!!  Enter = delete selected  ·  Ctrl+D = delete ALL  ·  Esc = cancel  !!";

      result = spawnSync("fzf", [
        "--ansi",
        `--delimiter=\t`,
        "--with-nth=1,2,3,4",
        `--header=${deleteHeader}`,
        "--header-first",
        "--reverse",
        "--info=inline",
        "--prompt=delete?> ",
        "--no-sort",
        "--expect=ctrl-d",
        "--margin=25%,30%",
        "--border=rounded",
      ], {
        stdio: ["pipe", "pipe", "inherit"],
        input: lines.join("\n"),
        encoding: "utf-8",
      });

      tui.start();
      tui.requestRender(true);

      if (result.status !== 0 || !result.stdout?.trim()) {
        done({ action: "cancel" });
        return { render: () => [], invalidate: () => {} };
      }

      const out2 = result.stdout.split("\n");
      if (out2.length > 0 && out2[out2.length - 1] === "") out2.pop(); // trailing newline
      const key2 = out2[0] ?? "";
      const path2 = parseFzfOutput(out2.slice(1).join("\n"));

      if (key2 === "ctrl-d") {
        done({ action: "delete-all" });
      } else if (!path2) {
        done({ action: "cancel" });
      } else {
        done({ action: "delete", path: path2 });
      }
      return { render: () => [], invalidate: () => {} };
    }

    // Enter or Ctrl+T
    tui.start();
    tui.requestRender(true);

    if (!path1) {
      done({ action: "cancel" });
    } else if (key1 === "ctrl-t") {
      done({ action: "new-tab", path: path1 });
    } else {
      done({ action: "resume", path: path1 });
    }
    return { render: () => [], invalidate: () => {} };
  });
}

export default function fzfResumeAll(pi: ExtensionAPI) {
  pi.registerCommand("fra", {
    description: "Resume a session from any project (fzf picker)",
    handler: async (_args, ctx) => {
      const sessions = await SessionManager.listAll();
      if (sessions.length === 0) {
        ctx.ui.notify("No sessions found", "warning");
        return;
      }

      const pick = await runFzfPicker(ctx, sessions);
      if (pick.action === "cancel") return;
      if (pick.action !== "delete-all" && !pick.path) return;

      // ── Delete all sessions (except the current one) ──
      if (pick.action === "delete-all") {
        const currentPath = ctx.sessionManager.getSessionFile();
        let deleted = 0;
        let failed = 0;
        let skipped = 0;
        for (const s of sessions) {
          if (currentPath && s.path === currentPath) {
            skipped++;
            continue;
          }
          try {
            unlinkSync(s.path);
            deleted++;
          } catch {
            failed++;
          }
        }
        ctx.ui.notify(`Deleted ${deleted} session(s)${skipped > 0 ? `, skipped ${skipped} (current)` : ""}${failed > 0 ? `, ${failed} failed` : ""}`, "info");
        return;
      }

      // Look up the full session info (for cwd and label)
      const session = sessions.find((s) => s.path === pick.path);

      // ── Delete action ──
      if (pick.action === "delete") {
        const label = session?.name || session?.firstMessage?.slice(0, 60) || pick.path;
        try {
          unlinkSync(pick.path);
          ctx.ui.notify(`Deleted: ${label}`, "info");
        } catch (e) {
          ctx.ui.notify(`Failed to delete: ${e instanceof Error ? e.message : String(e)}`, "error");
        }
        return;
      }

      // ── New tab action ──
      if (pick.action === "new-tab") {
        if (!session) {
          ctx.ui.notify("Session info not found", "warning");
          return;
        }
        if (openInNewHerdrTab(session)) {
          ctx.ui.notify(`Opened in new tab: ${session.name || session.firstMessage?.slice(0, 60) || "session"}`, "info");
        } else {
          ctx.ui.notify("Failed to open new herdr tab", "warning");
        }
        return;
      }

      // ── Resume in current tab ──
      await ctx.switchSession(pick.path, {
        withSession: async (newCtx) => {
          newCtx.ui.notify("Resumed session", "info");
        },
      });
    },
  });

  // No shortcut — /fra is invoked via command only. Ctrl+Shift+R belongs to /sess.
}
