/**
 * Session Picker (native) — reuses pi's own SessionSelectorComponent.
 *
 * Coexists with fzf-resume.ts (which owns /fra + Ctrl+Shift+R). This one
 * exposes /sess + Ctrl+Shift+S and opens the SAME selector pi uses for
 * /resume and --resume, so rendering is rock-solid (no smearing/ghosting),
 * with native search, delete-confirmation, rename, sort, and scope toggle.
 *
 *   /sess              Pick a session to resume.
 *   Ctrl+Shift+S       Same, via shortcut.
 *
 * Inside the picker: ↑↓ navigate, type to search, Enter resume, Esc cancel,
 *   Ctrl+T   open the selected session in a new herdr tab (ported from fzf).
 * (Delete/rename/sort/scope-toggle are the component's built-ins.)
 */

import { spawnSync } from "node:child_process";
import { unlinkSync } from "node:fs";
import {
	SessionManager,
	SessionSelectorComponent,
	type ExtensionAPI,
	type ExtensionCommandContext,
	type SessionInfo,
} from "@earendil-works/pi-coding-agent";
import { matchesKey, type Component, type Focusable } from "@earendil-works/pi-tui";

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
 * Open a session in a new herdr tab (ported verbatim from fzf-resume.ts).
 * Creates a tab with the session's cwd, then sends `pi --session <path>`.
 */
function openInNewHerdrTab(session: SessionInfo): boolean {
	const label = (session.name || session.firstMessage || "pi session")
		.replace(/["\\\t\n]/g, " ")
		.slice(0, 50);
	const cwd = session.cwd || process.cwd();

	const createOut = herdr(["tab", "create", "--cwd", cwd, "--label", label, "--focus"]);
	if (!createOut.trim()) return false;

	try {
		const parsed = JSON.parse(createOut.trim());
		const paneId: string | undefined = parsed?.result?.root_pane?.pane_id;
		if (!paneId) return false;

		const cmd = `pi --session ${session.path}`;

		spawnSync(
			"herdr",
			["pane", "wait-output", "--match", "%", "--timeout", "3000", paneId],
			{ stdio: ["pipe", "pipe", "pipe"], encoding: "utf-8", timeout: 10000 },
		);
		spawnSync("sleep", ["0.3"]);

		herdr(["pane", "send-text", paneId, cmd]);
		herdr(["pane", "send-keys", paneId, "Enter"]);
		return true;
	} catch {
		return false;
	}
}

/**
 * Wrapper around SessionSelectorComponent that intercepts Ctrl+T to open the
 * selected session in a new herdr tab, delegating everything else to the
 * native selector. Implements Focusable so the search input keeps cursor
 * positioning (propagates focus to the inner selector).
 */
class SessionPickerWrapper implements Component, Focusable {
	private selector: SessionSelectorComponent;
	private onNewTab: (path: string) => void;
	private _focused = false;

	constructor(selector: SessionSelectorComponent, onNewTab: (path: string) => void) {
		this.selector = selector;
		this.onNewTab = onNewTab;
	}

	get focused(): boolean {
		return this._focused;
	}

	set focused(value: boolean) {
		this._focused = value;
		// Propagate to the inner selector so its search input gets focus too.
		this.selector.focused = value;
	}

	invalidate(): void {
		this.selector.invalidate();
	}

	render(width: number): string[] {
		return this.selector.render(width);
	}

	handleInput(data: string): void {
		if (matchesKey(data, "ctrl+t")) {
			const path = this.selector.getSessionList().getSelectedSessionPath();
			if (path) this.onNewTab(path);
			return;
		}
		this.selector.handleInput(data);
	}
}

export default function sessionPickerExtension(pi: ExtensionAPI) {
	const openPicker = async (ctx: ExtensionCommandContext) => {
		const currentCwd = ctx.sessionManager.getCwd();
		const sessionDir = ctx.sessionManager.getSessionDir();
		const currentFile = ctx.sessionManager.getSessionFile();

		const currentLoader = (onProgress?: (loaded: number, total: number) => void) =>
			SessionManager.list(currentCwd, sessionDir, onProgress as never);
		const allLoader = (onProgress?: (loaded: number, total: number) => void) =>
			SessionManager.listAll(sessionDir, onProgress as never);

		const result = await ctx.ui.custom<string | null>(
			(tui, _theme, keybindings, done) => {
				const selector = new SessionSelectorComponent(
					currentLoader,
					allLoader,
					(path) => done(path), // onSelect → resume
					() => done(null), // onCancel
					() => done(null), // onExit → cancel (never quit pi)
					() => tui.requestRender(),
					{
						keybindings,
						showRenameHint: true,
						renameSession: async (sessionFilePath, nextName) => {
							const next = (nextName ?? "").trim();
							if (!next) return;
							try {
								const mgr = SessionManager.open(sessionFilePath);
								mgr.appendSessionInfo(next);
							} catch {
								// ignore rename failures
							}
						},
					},
					currentFile ?? undefined,
				);

				// Wire delete: the component shows the confirmation UI and calls
				// onDeleteSession to actually remove the file, then we refresh.
				const list = selector.getSessionList();
				list.onDeleteSession = async (sessionPath: string) => {
					if (currentFile && sessionPath === currentFile) return;
					try {
						unlinkSync(sessionPath);
					} catch {
						// ignore
					}
					const all = await SessionManager.listAll(sessionDir);
					list.setSessions(all, false);
					tui.requestRender();
				};

				// Ctrl+T: open the selected session in a new herdr tab.
				const onNewTab = async (path: string) => {
					done(null); // close the picker first
					const all = await SessionManager.listAll(sessionDir);
					const session = all.find((s) => s.path === path);
					if (!session) {
						ctx.ui.notify("Session info not found", "warning");
						return;
					}
					if (openInNewHerdrTab(session)) {
						ctx.ui.notify(
							`Opened in new tab: ${session.name || session.firstMessage?.slice(0, 60) || "session"}`,
							"info",
						);
					} else {
						ctx.ui.notify("Failed to open new herdr tab", "warning");
					}
				};

				return new SessionPickerWrapper(selector, onNewTab);
			},
		);

		if (!result) return;

		await ctx.switchSession(result, {
			withSession: async (c) => {
				c.ui.notify("Resumed session", "info");
			},
		});
	};

	pi.registerCommand("sess", {
		description: "Pick a session to resume (native pi selector)",
		handler: async (_args, ctx) => {
			await openPicker(ctx);
		},
	});

	pi.registerShortcut("ctrl+shift+r", {
		description: "Pick a session to resume (native pi selector)",
		handler: () => {
			pi.sendUserMessage("/sess", { expandPromptTemplates: true });
		},
	});
}
