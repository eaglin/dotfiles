/**
 * Todo List Extension (opencode-style, docked widget)
 *
 * Mirrors opencode's TodoWrite behavior so the model maintains the list
 * autonomously instead of the user having to force it.
 *
 * - Single `todo` tool that REPLACES the whole list in one call. Each item
 *   carries status: pending | in_progress | completed | cancelled. The model
 *   dumps its plan and rewrites it as it progresses — no ID juggling.
 * - The todo tool is available for multi-step tasks, but does not inject
 *   planning instructions into every prompt.
 * - The live list is shown in a DOCKED widget below the editor. It is part of
 *   the layout (never floats over / covers the chat). pi's TUI has no docked
 *   right sidebar, so a bottom widget is the closest non-floating option.
 * - /todos for a full-screen view, /todo-clear to wipe.
 *
 * State lives in tool result `details` (full list snapshot), so it
 * reconstructs correctly when navigating the session tree.
 */

import { StringEnum } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import type { Component, TUI } from "@earendil-works/pi-tui";
import { matchesKey, Text, truncateToWidth } from "@earendil-works/pi-tui";
import { Type } from "typebox";

type Status = "pending" | "in_progress" | "completed" | "cancelled";

interface Todo {
	text: string;
	status: Status;
}

interface TodoDetails {
	todos: Todo[];
}

const TodoParams = Type.Object({
	todos: Type.Array(
		Type.Object({
			text: Type.String({ description: "Actionable task" }),
			status: StringEnum(["pending", "in_progress", "completed", "cancelled"] as const),
		}),
		{ description: "Complete replacement list for a multi-step task" },
	),
});

const WIDGET_ID = "todo-list";

/** Stable holder so the widget and tool share the same live list. */
interface TodoState {
	todos: Todo[];
}

function statusMark(status: Status, theme: Theme): { glyph: string; color: (s: string) => string } {
	switch (status) {
		case "completed":
			return { glyph: "✓", color: (s) => theme.fg("success", s) };
		case "in_progress":
			return { glyph: "◐", color: (s) => theme.fg("accent", s) };
		case "cancelled":
			return { glyph: "✗", color: (s) => theme.fg("dim", s) };
		default:
			return { glyph: "○", color: (s) => theme.fg("dim", s) };
	}
}

function statusBody(status: Status, theme: Theme, text: string): string {
	switch (status) {
		case "completed":
		case "cancelled":
			return theme.fg("dim", text);
		case "in_progress":
			return theme.fg("text", theme.bold(text));
		default:
			return theme.fg("muted", text);
	}
}

/** Docked bottom widget. Renders the live todo list (never floats). */
class TodoWidget implements Component {
	private state: TodoState;
	private theme: Theme;
	private cachedWidth?: number;
	private cachedLines?: string[];

	constructor(state: TodoState, theme: Theme) {
		this.state = state;
		this.theme = theme;
	}

	invalidate(): void {
		this.cachedWidth = undefined;
		this.cachedLines = undefined;
	}

	render(width: number): string[] {
		if (this.cachedLines && this.cachedWidth === width) return this.cachedLines;

		const th = this.theme;
		const todos = this.state.todos;
		const total = todos.length;
		const done = todos.filter((t) => t.status === "completed" || t.status === "cancelled").length;
		const inProg = todos.filter((t) => t.status === "in_progress");

		const lines: string[] = [];
		const header =
			th.fg("accent", th.bold("📋 Todos")) + th.fg("muted", `  ${done}/${total} done`);
		lines.push(header);

		if (total === 0) {
			lines.push(th.fg("dim", "  (no plan yet — the agent will add one for non-trivial tasks)"));
		} else {
			const visible = todos.slice(0, 12);
			for (const t of visible) {
				const { glyph, color } = statusMark(t.status, th);
				const body = statusBody(t.status, th, t.text);
				lines.push(truncateToWidth(`  ${color(glyph)} ${body}`, width));
			}
			if (todos.length > visible.length) {
				lines.push(th.fg("dim", `  … ${todos.length - visible.length} more (/todos)`));
			}
			if (inProg.length === 0 && done < total) {
				lines.push(th.fg("dim", "  (no item in progress)"));
			}
		}

		this.cachedWidth = width;
		this.cachedLines = lines;
		return lines;
	}
}

/** Full-screen component for the /todos command. */
class TodoListComponent implements Component {
	private todos: Todo[];
	private theme: Theme;
	private onClose: () => void;
	private cachedWidth?: number;
	private cachedLines?: string[];

	constructor(todos: Todo[], theme: Theme, onClose: () => void) {
		this.todos = todos;
		this.theme = theme;
		this.onClose = onClose;
	}

	invalidate(): void {
		this.cachedWidth = undefined;
		this.cachedLines = undefined;
	}

	handleInput(data: string): void {
		if (matchesKey(data, "escape") || matchesKey(data, "ctrl+c")) {
			this.onClose();
		}
	}

	render(width: number): string[] {
		if (this.cachedLines && this.cachedWidth === width) return this.cachedLines;

		const lines: string[] = [];
		const th = this.theme;

		lines.push("");
		const title = th.fg("accent", " Todos ");
		const headerLine =
			th.fg("borderMuted", "─".repeat(3)) + title + th.fg("borderMuted", "─".repeat(Math.max(0, width - 10)));
		lines.push(truncateToWidth(headerLine, width));
		lines.push("");

		if (this.todos.length === 0) {
			lines.push(truncateToWidth(`  ${th.fg("dim", "No todos yet.")}`, width));
		} else {
			const done = this.todos.filter(
				(t) => t.status === "completed" || t.status === "cancelled",
			).length;
			lines.push(truncateToWidth(`  ${th.fg("muted", `${done}/${this.todos.length} done`)}`, width));
			lines.push("");

			for (const t of this.todos) {
				const { glyph, color } = statusMark(t.status, th);
				const body = statusBody(t.status, th, t.text);
				lines.push(truncateToWidth(`  ${color(glyph)} ${body}`, width));
			}
		}

		lines.push("");
		lines.push(truncateToWidth(`  ${th.fg("dim", "Press Escape to close")}`, width));
		lines.push("");

		this.cachedWidth = width;
		this.cachedLines = lines;
		return lines;
	}
}

export default function todoListExtension(pi: ExtensionAPI) {
	const state: TodoState = { todos: [] };
	let capturedTui: TUI | null = null;
	let widget: TodoWidget | null = null;

	const rerender = () => {
		try {
			capturedTui?.requestRender();
		} catch {
			// TUI may be torn down during shutdown; ignore.
		}
	};

	const installWidget = (ctx: ExtensionContext) => {
		if (!ctx.hasUI) return;
		ctx.ui.setWidget(
			WIDGET_ID,
			(tui, theme) => {
				capturedTui = tui;
				widget = new TodoWidget(state, theme);
				return widget;
			},
			{ placement: "belowEditor" },
		);
		rerender();
	};

	/** Replay the last todo toolResult on this branch. */
	const reconstructState = (ctx: ExtensionContext) => {
		state.todos = [];
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type !== "message") continue;
			const msg = entry.message;
			if (msg.role !== "toolResult" || msg.toolName !== "todo") continue;
			const details = msg.details as TodoDetails | undefined;
			if (details?.todos) state.todos = details.todos;
		}
		if (widget) widget.invalidate();
		rerender();
	};

	pi.on("session_start", async (_event, ctx) => {
		reconstructState(ctx);
		installWidget(ctx);
	});
	pi.on("session_tree", async (_event, ctx) => reconstructState(ctx));
	pi.on("turn_start", async () => rerender());
	pi.on("turn_end", async () => rerender());
	pi.on("session_shutdown", async () => {
		widget = null;
		capturedTui = null;
	});

	// The single replace-the-whole-list tool (opencode TodoWrite style).
	pi.registerTool({
		name: "todo",
		label: "Todo",
		description: "Create or replace a todo list for a multi-step task. Skip for simple or informational requests. Keep one item in_progress; mark items completed after verification.",
		parameters: TodoParams,

		async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
			state.todos = (params.todos ?? []).map((t) => ({ text: t.text, status: t.status }));
			if (widget) widget.invalidate();
			rerender();

			const total = state.todos.length;
			const done = state.todos.filter(
				(t) => t.status === "completed" || t.status === "cancelled",
			).length;
			const inProg = state.todos.filter((t) => t.status === "in_progress").length;

			const summary =
				total === 0
					? "Cleared the todo list."
					: `Updated todo list: ${done}/${total} done${
							inProg > 0 ? `, ${inProg} in progress` : ""
						}.\n` +
						state.todos
							.map((t) => {
								const m =
									t.status === "completed"
										? "✓"
										: t.status === "in_progress"
											? "◐"
											: t.status === "cancelled"
												? "✗"
												: "○";
								return `  ${m} ${t.text}`;
							})
							.join("\n");

			return {
				content: [{ type: "text", text: summary }],
				details: { todos: [...state.todos] } as TodoDetails,
			};
		},

		renderCall(args, theme, _context) {
			const n = args.todos?.length ?? 0;
			return new Text(
				theme.fg("toolTitle", theme.bold("todo ")) + theme.fg("muted", `write ${n} item(s)`),
				0,
				0,
			);
		},

		renderResult(result, _opts, theme, _context) {
			const details = result.details as TodoDetails | undefined;
			const list = details?.todos ?? [];
			if (list.length === 0) return new Text(theme.fg("dim", "(empty)"), 0, 0);
			let s = "";
			for (const t of list) {
				const { glyph, color } = statusMark(t.status, theme);
				const body = statusBody(t.status, theme, t.text);
				s += `${color(glyph)} ${body}\n`;
			}
			return new Text(s.trimEnd(), 0, 0);
		},
	});

	// /todos — full-screen view
	pi.registerCommand("todos", {
		description: "Show the todo list in a full-screen panel",
		handler: async (_args, ctx) => {
			if (ctx.mode !== "tui") {
				ctx.ui.notify("/todos requires interactive mode", "error");
				return;
			}
			await ctx.ui.custom<void>((_tui, theme, _kb, done) => {
				return new TodoListComponent(state.todos, theme, () => done());
			});
		},
	});

	// /todo-clear — quick wipe
	pi.registerCommand("todo-clear", {
		description: "Clear all todos",
		handler: async (_args, ctx) => {
			state.todos = [];
			if (widget) widget.invalidate();
			rerender();
			ctx.ui.notify("Cleared all todos", "info");
		},
	});
}
