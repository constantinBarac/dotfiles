---
name: h-implement-opencode-sessions
branch: feature/opencode-sessions
status: pending
created: 2026-02-16
---

# Port cc-sessions Framework to OpenCode Plugin System

## Problem/Goal
Bring the cc-sessions workflow management framework (DAIC mode enforcement, task lifecycle, specialized agents, protocol automation, context preservation) to OpenCode's plugin system, achieving feature parity using OpenCode-native APIs.

## Success Criteria
- [ ] DAIC mode enforcement works via `permission.ask` hook — write/edit/bash tools blocked in discussion mode
- [ ] Trigger phrase detection via `chat.message` hook switches modes and loads protocols
- [ ] Protocol instructions injected via `experimental.chat.system.transform` persist across turns
- [ ] 5 specialized agents defined in `.opencode/agents/` with proper tool restrictions and prompts
- [ ] Task lifecycle works end-to-end: creation → startup → implementation → completion
- [ ] File-based state (`sessions-state.json`) and config (`sessions-config.json`) management
- [ ] Context compaction hook preserves task state, protocol state, and work log
- [ ] Todo validation via `tool.execute.before` on `todowrite` prevents scope creep
- [ ] Sessions CLI available via custom commands (`.opencode/commands/`)
- [ ] Branch enforcement via permission gating on bash git commands
- [ ] All features work within a single monolithic plugin + agent/command definitions

## Implementation Architecture

### Plugin Structure
```
.opencode/
├── plugins/
│   └── sessions/
│       ├── index.ts              # Plugin entry — registers all hooks
│       ├── state.ts              # State manager (sessions-state.json)
│       ├── config.ts             # Config loader (sessions-config.json)
│       ├── hooks/
│       │   ├── daic-enforcer.ts  # permission.ask — block tools per mode
│       │   ├── trigger-detect.ts # chat.message — detect trigger phrases
│       │   ├── system-inject.ts  # experimental.chat.system.transform — inject protocols
│       │   ├── post-tool.ts      # tool.execute.after — auto mode switch, cleanup
│       │   ├── todo-guard.ts     # tool.execute.before on todowrite — validate changes
│       │   └── compaction.ts     # experimental.session.compacting — preserve context
│       └── tools/
│           └── sessions-api.ts   # Custom tool for state/config/task management
├── agents/
│   ├── context-gathering.md      # Read-only, creates context manifests
│   ├── code-review.md            # Read-only, reviews code quality/security
│   ├── logging.md                # Edit-enabled (task file only), consolidates logs
│   ├── context-refinement.md     # Edit-enabled (task file only), updates context
│   └── service-documentation.md  # Edit + bash, updates AGENTS.md/docs
├── commands/
│   ├── sessions-state.md         # /sessions-state — show/modify state
│   ├── sessions-config.md        # /sessions-config — show/modify config
│   └── sessions-tasks.md         # /sessions-tasks — list/manage tasks
└── package.json                  # @opencode-ai/plugin dependency
```

### Hook → Feature Mapping
| Hook | Feature | Implementation |
|------|---------|----------------|
| `permission.ask` | DAIC enforcement | Check state.mode, deny write tools in discussion |
| `chat.message` | Trigger detection | Scan parts for phrases, update state, set protocol |
| `experimental.chat.system.transform` | Protocol injection | Read active protocol + task context, append to system[] |
| `tool.execute.after` | Auto-return to discussion | Detect all todos complete → switch mode |
| `tool.execute.before` | Todo validation | Intercept todowrite, compare against approved list |
| `experimental.session.compacting` | Context preservation | Inject task state, protocol step, work log into context[] |
| `event` | Session init | Listen for session.created, load task, check state |

### Phase Plan
1. **Core foundation** — state manager, config loader, plugin shell with hook registration
2. **DAIC enforcement** — permission.ask hook, mode state, trigger detection via chat.message
3. **Protocol system** — system prompt injection, protocol definitions, todo validation
4. **Agent definitions** — 5 agents as .opencode/agents/*.md with proper prompts/restrictions
5. **Task lifecycle** — creation/startup/completion protocols adapted for OpenCode
6. **CLI commands** — custom commands for state/config/task management
7. **Context compaction** — compaction hook with task-aware context preservation
8. **Integration testing** — end-to-end workflow validation

## Context Manifest

### How cc-sessions Currently Works: Full Architecture

The cc-sessions framework is a Claude Code hook-based workflow management system that enforces a Discussion-Alignment-Implementation-Check (DAIC) pattern. It lives entirely in `/Users/ibar/dotfiles/sessions/` and operates through 6 JavaScript hook files that Claude Code invokes at different lifecycle points, reading/writing two JSON files for persistent state.

#### State Management (`/Users/ibar/dotfiles/sessions/hooks/shared_state.js`)

This is the foundational module -- all other hooks import from it. It provides atomic file locking, state/config loading, and the full class hierarchy. Key points:

**Project root detection**: Walks up from cwd looking for `.claude` directory, or uses `CLAUDE_PROJECT_DIR` env var. All paths are relative to this root.

**State file** at `sessions/sessions-state.json`, protected by a directory-based lock at `sessions/sessions-state.lock/`. The `editState(callback)` function acquires the lock, loads state, runs the callback, then atomically writes back. The state schema (class `SessionsState`) contains:

```typescript
{
  version: string,           // package version
  current_task: {            // TaskState
    name: string | null,
    file: string | null,     // relative path from sessions/tasks/
    branch: string | null,
    status: string | null,   // "pending" | "in-progress" | "completed" | "blocked"
    created: string | null,
    started: string | null,
    updated: string | null,
    dependencies: string | null,
    submodules: string[] | null
  },
  active_protocol: string | null,  // "context-compaction" | "task-creation" | "task-startup" | "task-completion"
  api: {                     // APIPerms
    startup_load: boolean,
    completion: boolean,
    todos_clear: boolean
  },
  mode: "discussion" | "implementation",
  todos: {                   // SessionsTodos
    active: Array<{content: string, status: "pending"|"in_progress"|"completed", activeForm: string|null}>,
    stashed: Array<same>
  },
  model: "opus" | "sonnet" | "unknown",
  flags: {                   // SessionsFlags
    context_85: boolean,
    context_90: boolean,
    subagent: boolean,
    noob: boolean,
    bypass_mode: boolean
  },
  metadata: {}
}
```

**Config file** at `sessions/sessions-config.json`, schema (class `SessionsConfig`):

```typescript
{
  trigger_phrases: {
    implementation_mode: string[],  // ["yert", "yeet"]
    discussion_mode: string[],      // ["SILENCE"]
    task_creation: string[],        // ["mek:"]
    task_startup: string[],         // ["start^"]
    task_completion: string[],      // ["finito"]
    context_compaction: string[]    // ["squish"]
  },
  blocked_actions: {
    implementation_only_tools: string[],  // ["Write", "Edit", "MultiEdit", "NotebookEdit"]
    bash_read_patterns: string[],
    bash_write_patterns: string[],
    extrasafe: boolean
  },
  git_preferences: {
    add_pattern: "ask" | "all",
    default_branch: string,          // "master"
    commit_style: "conventional" | "simple" | "detailed",
    auto_merge: boolean,
    auto_push: boolean,
    has_submodules: boolean
  },
  environment: {
    os: "linux" | "macos" | "windows",
    shell: "bash" | "zsh" | "fish" | "powershell" | "cmd",
    developer_name: string           // "costele"
  },
  features: {
    branch_enforcement: boolean,
    task_detection: boolean,
    auto_ultrathink: boolean,
    icon_style: "nerd_fonts" | "emoji" | "ascii",
    context_warnings: { warn_85: boolean, warn_90: boolean }
  }
}
```

#### Hook 1: PreToolUse / DAIC Enforcer (`sessions_enforce.js`)

This is the gatekeeper. It reads stdin as JSON `{tool_name, tool_input}`, loads state and config, then:

1. **CI bypass**: If GitHub Actions environment detected, exits 0 (allow).
2. **Bash in discussion mode**: If `mode === "discussion"` and tool is Bash, checks if command is read-only using extensive pattern matching. Read-only commands (grep, cat, ls, git status, etc.) are allowed. Write commands (rm, mv, pip install, npm install, etc.) are blocked. The `isBashReadOnly()` function splits on `|`, `&&`, `||`, checks each segment's first word against READONLY_FIRST and WRITE_FIRST sets, and checks for redirections. Special handling for `sed -i`, `awk` with file output, `find -delete`, `xargs` with write commands. Exits 2 with error message if blocked.
3. **State file protection**: Blocks direct modification of `sessions-state.json` via any tool.
4. **Discussion mode tool blocking**: If mode is "discussion" and tool is in `blocked_actions.implementation_only_tools`, blocks with exit 2.
5. **TodoWrite validation**: When TodoWrite is used, compares incoming todo content names against active todo names. If names differ, it clears todos, reverts to discussion mode, and outputs the "SHAME RITUAL" message format. If names match, stores the incoming todos via `editState`.
6. **Branch enforcement**: For file-editing tools, checks git branch matches the task's expected branch. Also validates submodule branch consistency.

Exit codes: 0 = allow, 2 = block with stderr feedback to Claude.

#### Hook 2: UserPromptSubmit / Trigger Detection (`user_messages.js`)

Reads stdin as `{prompt, transcript_path}`. Scans the user's prompt text for trigger phrases (case-sensitive for ALL_CAPS phrases, case-insensitive otherwise). The hook:

1. **Token monitoring**: Reads the transcript JSONL file, finds the most recent main-chain message's usage data, calculates context percentage. Shows warnings at 85% and 90% (once per session via flags).
2. **Implementation mode trigger**: If in discussion mode and implementation phrase found, sets mode to "implementation" and injects DAIC rules into context.
3. **Discussion mode trigger (EMERGENCY STOP)**: If in implementation mode and discussion phrase found, reverts to discussion, clears todos.
4. **Task creation trigger**: Loads `protocols/task-creation/task-creation.md`, applies template variables (`{submodules_field}`, `{todos}`), defines 5 protocol todos, stashes existing todos, switches to implementation mode, sets `active_protocol = "task-creation"`.
5. **Task startup trigger**: Similar pattern with `protocols/task-startup/task-startup.md`, defines 4 todos (git status, branch, verify manifest, gather context), injects startup-load API instructions.
6. **Task completion trigger**: Loads `protocols/task-completion/task-completion.md` with extensive template variable substitution for git operations. Defines 5-7 todos depending on config (auto_merge, auto_push, directory tasks).
7. **Context compaction trigger**: Loads `protocols/context-compaction/context-compaction.md`, defines 3 todos (logging, context-refinement, service-documentation agents).

Output format: `{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": context_string}}`

#### Hook 3: PostToolUse (`post_tool_use.js`)

Reads stdin `{tool_name, tool_input, cwd}`. Handles:

1. **Directory change feedback**: If Bash command contains "cd", emits working directory reminder.
2. **Subagent cleanup**: After Task tool completes, clears subagent flag and removes transcript directory.
3. **Todo completion detection**: When TodoWrite is used and all todos are "completed", triggers auto-return to discussion mode. Special handling for task completion protocol (clears task state) and stashed todo restoration.
4. **Implementation mode without todos**: Reminds Claude to add todos if in implementation mode with no active todos.
5. **Task file auto-update**: When Edit/Write/MultiEdit modifies the current task file, re-parses frontmatter to sync state.
6. **API permission window**: Disables `todos_clear` permission after any non-clear tool use.

#### Hook 4: SessionStart (`session_start.js`)

Runs on new Claude Code session. Clears session flags and active todos. Restores stashed todos from previous session. Loads current task file content or lists available tasks grouped by index. Checks for cc-sessions npm package updates. Updates task status from "pending" to "in-progress" if active task found.

#### Hook 5: SubagentHooks (`subagent_hooks.js`)

Runs on PreToolUse for Task tool. Sets `flags.subagent = true`. Processes the transcript JSONL to extract conversation from first edit tool onward, cleans it, chunks it into 24KB batches, and saves to `sessions/transcripts/{subagent_type}/`. This gives subagents access to the parent conversation context.

#### Protocol Files

All protocols live in `/Users/ibar/dotfiles/sessions/protocols/` and use `{variable}` template syntax that gets replaced by the trigger detection hook.

**task-creation.md** (`/Users/ibar/dotfiles/sessions/protocols/task-creation/task-creation.md`): Instructions for creating a new task file. Covers priority prefixes (h/m/l/?), type prefixes (implement/fix/refactor/research/experiment/migrate/test/docs), file vs directory decision, naming proposal format, template copying, success criteria discussion, context-gathering agent invocation, index file updates, and committing.

**task-startup.md** (`/Users/ibar/dotfiles/sessions/protocols/task-startup/task-startup.md`): Git status check, branch creation/checkout, context manifest verification, context gathering, initial planning in discussion mode with todo proposal format.

**task-completion.md** (`/Users/ibar/dotfiles/sessions/protocols/task-completion/task-completion.md`): Pre-completion checks, code-review/service-documentation/logging agents, index file updates, task archival to `done/`, git staging/commit/merge/push operations.

**context-compaction.md** (`/Users/ibar/dotfiles/sessions/protocols/context-compaction/context-compaction.md`): Run logging agent, context-refinement agent, service-documentation agent. Simple 3-step process for preserving state before context window clear.

### OpenCode Plugin System: Full API Reference

The OpenCode plugin system at `/Users/ibar/dotfiles/.opencode/` uses `@opencode-ai/plugin` v1.1.36 (ESM, TypeScript). The plugin SDK uses zod v4.1.8 for tool argument schemas.

#### Plugin Entry Point

A plugin is an async function that receives a `PluginInput` and returns a `Hooks` object:

```typescript
// From /Users/ibar/dotfiles/.opencode/node_modules/@opencode-ai/plugin/dist/index.d.ts
type PluginInput = {
  client: ReturnType<typeof createOpencodeClient>;  // OpencodeClient instance
  project: Project;          // { id, worktree, vcsDir?, vcs?, time }
  directory: string;         // Working directory
  worktree: string;          // Git worktree root
  serverUrl: URL;            // OpenCode server URL
  $: BunShell;               // Bun shell for running commands
};

type Plugin = (input: PluginInput) => Promise<Hooks>;
```

#### Hooks Interface

All hooks are optional. The pattern is `hookName?: (input: InputType, output: OutputType) => Promise<void>`. The `output` parameter is mutable -- you modify it to change behavior.

```typescript
interface Hooks {
  // Event listener -- fires on any OpenCode event
  event?: (input: { event: Event }) => Promise<void>;

  // Called when config is loaded/changed
  config?: (input: Config) => Promise<void>;

  // Register custom tools
  tool?: { [key: string]: ToolDefinition };

  // Auth hook for custom providers (not relevant here)
  auth?: AuthHook;

  // Fires when user sends a message. Input has sessionID, agent, model, messageID, variant.
  // Output has mutable message (UserMessage) and parts (Part[]).
  "chat.message"?: (input: {
    sessionID: string;
    agent?: string;
    model?: { providerID: string; modelID: string };
    messageID?: string;
    variant?: string;
  }, output: {
    message: UserMessage;
    parts: Part[];
  }) => Promise<void>;

  // Modify LLM parameters (temperature, topP, topK, options)
  "chat.params"?: (input: {...}, output: {
    temperature: number;
    topP: number;
    topK: number;
    options: Record<string, any>;
  }) => Promise<void>;

  // Permission gating -- THIS IS THE DAIC ENFORCEMENT POINT
  // input is a Permission object, output.status can be set to "allow", "deny", or "ask"
  "permission.ask"?: (input: Permission, output: {
    status: "ask" | "deny" | "allow";
  }) => Promise<void>;

  // Fires before a slash command executes. Can modify parts[] injected into conversation.
  "command.execute.before"?: (input: {
    command: string;
    sessionID: string;
    arguments: string;
  }, output: {
    parts: Part[];
  }) => Promise<void>;

  // Fires before a tool executes. Can modify args.
  "tool.execute.before"?: (input: {
    tool: string;       // Tool name like "edit", "bash", "todowrite"
    sessionID: string;
    callID: string;
  }, output: {
    args: any;          // Mutable tool arguments
  }) => Promise<void>;

  // Fires after a tool executes. Can modify title, output text, metadata.
  "tool.execute.after"?: (input: {
    tool: string;
    sessionID: string;
    callID: string;
  }, output: {
    title: string;
    output: string;
    metadata: any;
  }) => Promise<void>;

  // Experimental: Transform the full message history
  "experimental.chat.messages.transform"?: (input: {}, output: {
    messages: { info: Message; parts: Part[] }[];
  }) => Promise<void>;

  // Experimental: Transform the system prompt -- THIS IS THE PROTOCOL INJECTION POINT
  // output.system is a mutable string array. Push to it to add system instructions.
  "experimental.chat.system.transform"?: (input: {
    sessionID: string;
  }, output: {
    system: string[];
  }) => Promise<void>;

  // Experimental: Called before compaction. Add context[] strings or replace prompt entirely.
  "experimental.session.compacting"?: (input: {
    sessionID: string;
  }, output: {
    context: string[];
    prompt?: string;
  }) => Promise<void>;
}
```

#### Permission Type

```typescript
type Permission = {
  id: string;
  type: string;        // Permission type like "edit", "bash", "webfetch"
  pattern?: string | string[];  // Pattern being requested (e.g., file paths, commands)
  sessionID: string;
  messageID: string;
  callID?: string;
  title: string;       // Human-readable description
  metadata: { [key: string]: unknown };
  time: { created: number };
};
```

The `type` field is the key for DAIC enforcement. For example, `type: "edit"` for file edits, `type: "bash"` for shell commands. The `pattern` field contains the file path or command pattern.

#### UserMessage Type

```typescript
type UserMessage = {
  id: string;
  sessionID: string;
  role: "user";
  time: { created: number };
  summary?: { title?: string; body?: string; diffs: FileDiff[] };
  agent: string;
  model: { providerID: string; modelID: string };
  system?: string;
  tools?: { [key: string]: boolean };
};
```

#### Part Type (union)

```typescript
type Part = TextPart | SubtaskPart | ReasoningPart | FilePart | ToolPart |
            StepStartPart | StepFinishPart | SnapshotPart | PatchPart |
            AgentPart | RetryPart | CompactionPart;

type TextPart = {
  id: string; sessionID: string; messageID: string;
  type: "text";
  text: string;
  synthetic?: boolean; ignored?: boolean;
  time?: { start: number; end?: number };
  metadata?: { [key: string]: unknown };
};

type ToolPart = {
  id: string; sessionID: string; messageID: string;
  type: "tool";
  callID: string;
  tool: string;           // Tool name
  state: ToolState;       // pending | running | completed | error
  metadata?: { [key: string]: unknown };
};

type ToolState = ToolStatePending | ToolStateRunning | ToolStateCompleted | ToolStateError;
// ToolStateCompleted has: { status: "completed", input: {}, output: string, title: string, metadata: {}, time: {...} }
```

#### Tool Definition API

```typescript
// From /Users/ibar/dotfiles/.opencode/node_modules/@opencode-ai/plugin/dist/tool.d.ts
import { z } from "zod";

type ToolContext = {
  sessionID: string;
  messageID: string;
  agent: string;
  abort: AbortSignal;
  metadata(input: { title?: string; metadata?: { [key: string]: any } }): void;
  ask(input: {
    permission: string;
    patterns: string[];
    always: string[];
    metadata: { [key: string]: any };
  }): Promise<void>;
};

function tool<Args extends z.ZodRawShape>(input: {
  description: string;
  args: Args;
  execute(args: z.infer<z.ZodObject<Args>>, context: ToolContext): Promise<string>;
}): ToolDefinition;

// tool.schema === z  (Zod instance for defining argument schemas)
```

#### BunShell

```typescript
// From /Users/ibar/dotfiles/.opencode/node_modules/@opencode-ai/plugin/dist/shell.d.ts
interface BunShell {
  (strings: TemplateStringsArray, ...expressions: ShellExpression[]): BunShellPromise;
  braces(pattern: string): string[];
  escape(input: string): string;
  env(newEnv?: Record<string, string | undefined>): BunShell;
  cwd(newCwd?: string): BunShell;
  nothrow(): BunShell;
  throws(shouldThrow: boolean): BunShell;
}
// Usage: const result = await $`git status`.text();
```

#### OpenCode SDK Client API Surface

The `client` parameter (type `OpencodeClient`) provides namespaced access to the OpenCode server:

```typescript
class OpencodeClient {
  global: { event() }                    // SSE event stream
  project: { list(), current() }         // Project management
  session: {                             // Session CRUD + messaging
    list(), create(), get(), update(), delete(),
    status(), children(), todo(),
    init(), fork(), abort(),
    share(), unshare(),
    diff(), summarize(),
    messages(), message(),
    prompt(), promptAsync(),
    command(), shell(),
    revert(), unrevert()
  }
  config: { get(), update(), providers() }
  tool: { ids(), list() }
  path: { get() }                        // Get state/config/worktree/directory paths
  vcs: { get() }                         // Get current branch info
  file: { list(), read(), status() }
  find: { text(), files(), symbols() }
  app: { log(), agents() }
  tui: {                                 // TUI control
    appendPrompt(), submitPrompt(), clearPrompt(),
    openHelp(), openSessions(), openThemes(), openModels(),
    executeCommand(), showToast(), publish(),
    control: { next(), response() }
  }
  event: { subscribe() }
  // ... mcp, lsp, formatter, pty, provider, auth
}
```

Key APIs for sessions plugin:
- `client.session.todo(sessionID)` -- get todo list for a session
- `client.session.messages(sessionID)` -- get message history
- `client.vcs.get()` -- get current branch
- `client.path.get()` -- get state/config/worktree paths
- `client.app.agents()` -- list available agents
- `client.tui.showToast()` -- show notifications

#### OpenCode Agent Configuration

Agents are defined via the `agent` field in `opencode.json` config or as markdown files in `.opencode/agents/`. The `AgentConfig` type:

```typescript
type AgentConfig = {
  model?: string;                    // e.g., "anthropic/claude-opus-4"
  temperature?: number;
  top_p?: number;
  prompt?: string;                   // System prompt (markdown)
  tools?: { [key: string]: boolean }; // Tool whitelist/blacklist
  disable?: boolean;
  description?: string;              // When to use this agent
  mode?: "subagent" | "primary" | "all";
  color?: string;                    // Hex color code
  maxSteps?: number;                 // Max agentic iterations
  permission?: {
    edit?: "ask" | "allow" | "deny";
    bash?: ("ask" | "allow" | "deny") | { [key: string]: "ask" | "allow" | "deny" };
    webfetch?: "ask" | "allow" | "deny";
    doom_loop?: "ask" | "allow" | "deny";
    external_directory?: "ask" | "allow" | "deny";
  };
};
```

Markdown agent files use YAML frontmatter with these same fields. Example format for `.opencode/agents/context-gathering.md`:

```markdown
---
description: "Read-only agent that creates context manifests for tasks"
mode: subagent
tools:
  edit: false
  bash: false
permission:
  edit: deny
  bash: deny
---

System prompt content here...
```

#### OpenCode Todo Type

OpenCode has a built-in Todo system. The SDK defines:

```typescript
type Todo = {
  content: string;     // Brief description of the task
  status: string;      // "pending" | "in_progress" | "completed" | "cancelled"
  priority: string;    // "high" | "medium" | "low"
  id: string;          // Unique identifier
};
```

This differs from cc-sessions' CCTodo which has `{content, status, activeForm}`. The OpenCode version adds `priority` and `id`, removes `activeForm`.

#### Event Types for Session Init

The `event` hook receives all OpenCode events. Key ones for session initialization:

```typescript
type EventSessionCreated = { type: "session.created"; properties: { info: Session } };
type EventSessionUpdated = { type: "session.updated"; properties: { info: Session } };
type EventTodoUpdated = { type: "todo.updated"; properties: { sessionID: string; todos: Todo[] } };
type EventFileEdited = { type: "file.edited"; properties: { file: string } };
type EventVcsBranchUpdated = { type: "vcs.branch.updated"; properties: { branch?: string } };
type EventSessionCompacted = { type: "session.compacted"; properties: { sessionID: string } };
```

### What's Already Set Up in .opencode/

The `.opencode/` directory currently has:

- `/Users/ibar/dotfiles/.opencode/package.json` -- only has `@opencode-ai/plugin: "1.1.36"` as dependency
- `/Users/ibar/dotfiles/.opencode/node_modules/` -- has `@opencode-ai/plugin` and `@opencode-ai/sdk` (and zod) installed
- `/Users/ibar/dotfiles/.opencode/plans/` -- empty directory
- `/Users/ibar/dotfiles/.opencode/.gitignore` -- exists (likely ignoring node_modules)

No `opencode.json` exists at the repo root. No plugins, agents, or commands directories exist yet. Everything needs to be created from scratch.

### Implementation Mapping: cc-sessions Hooks to OpenCode Hooks

#### 1. DAIC Enforcement (cc: `sessions_enforce.js` -> oc: `permission.ask`)

The cc-sessions PreToolUse hook reads tool_name/tool_input from stdin and exits with code 0 (allow) or 2 (deny+feedback). In OpenCode, the `permission.ask` hook receives a `Permission` object with `type` (the permission category) and `pattern` (the resource). To deny, set `output.status = "deny"`. To allow without asking the user, set `output.status = "allow"`.

The key mapping: `permission.type` values in OpenCode are `"edit"`, `"bash"`, `"webfetch"`, `"doom_loop"`, `"external_directory"`. For DAIC, we need to deny `"edit"` in discussion mode. For bash, the `pattern` field likely contains the command string, which we can analyze for read-only vs write behavior.

**Critical difference**: cc-sessions can intercept specific tool names (Write, Edit, MultiEdit, NotebookEdit, TodoWrite). OpenCode `permission.ask` operates on permission categories (edit, bash), not individual tool names. The TodoWrite interception needs to happen via `tool.execute.before` instead, checking `input.tool === "todowrite"`.

#### 2. Trigger Detection (cc: `user_messages.js` -> oc: `chat.message`)

The cc-sessions UserPromptSubmit hook receives the raw prompt text. In OpenCode, `chat.message` receives `{message: UserMessage, parts: Part[]}`. The user's text content is in the `parts` array as `TextPart` objects. To scan for trigger phrases, iterate `output.parts` and check `part.type === "text"` then scan `part.text`.

**Critical difference**: cc-sessions UserPromptSubmit injects additional context by outputting `{"hookSpecificOutput": {"additionalContext": text}}`. OpenCode's `chat.message` hook cannot directly inject system-level context -- it can only modify the message/parts. Protocol injection must happen via `experimental.chat.system.transform` which fires on every LLM call. So the chat.message hook should detect triggers, update state, and the system.transform hook reads state and injects protocols.

#### 3. Protocol Injection (cc: same hook -> oc: `experimental.chat.system.transform`)

This hook fires before every LLM call. It receives `output.system` (a `string[]`). Push protocol text to this array to inject it as system instructions. Read `active_protocol` from state file, load the appropriate protocol markdown, and push it. This replaces the cc-sessions pattern of injecting context via UserPromptSubmit additionalContext.

#### 4. Post-Tool Handling (cc: `post_tool_use.js` -> oc: `tool.execute.after`)

The cc-sessions PostToolUse hook handles todo completion detection, task file auto-update, and subagent cleanup. In OpenCode, `tool.execute.after` gets `{tool, sessionID, callID}` and mutable `{title, output, metadata}`. To detect todo completion, check `input.tool === "todowrite"` then load state to see if all todos are complete. To inject feedback, modify `output.output` to append messages.

#### 5. Todo Validation (cc: `sessions_enforce.js` TodoWrite section -> oc: `tool.execute.before`)

In cc-sessions, todo validation happens in the PreToolUse hook when tool_name is "TodoWrite". In OpenCode, use `tool.execute.before` where `input.tool === "todowrite"`. The `output.args` contains the mutable todo arguments. Compare against stored state todos.

#### 6. Context Compaction (cc: not a separate hook -> oc: `experimental.session.compacting`)

OpenCode has a dedicated hook for compaction. Push task state, protocol state, work log, and active todos into `output.context[]` so they survive compaction. This replaces the cc-sessions approach where compaction was a manual protocol triggered by the "squish" phrase.

#### 7. Session Init (cc: `session_start.js` -> oc: `event` hook)

OpenCode has no dedicated SessionStart hook. Use the `event` hook, listen for `event.type === "session.created"`, then clear flags, load task, inject initial context. Alternatively, `experimental.chat.system.transform` can serve this purpose since it fires on every turn -- check if state needs initialization.

### What Needs to Be Created

#### File Structure

```
.opencode/
├── plugins/
│   └── sessions/
│       ├── index.ts              # Plugin entry point
│       ├── state.ts              # State manager (read/write sessions-state.json)
│       ├── config.ts             # Config loader (read sessions-config.json)
│       ├── hooks/
│       │   ├── daic-enforcer.ts  # permission.ask handler
│       │   ├── trigger-detect.ts # chat.message handler
│       │   ├── system-inject.ts  # system.transform handler
│       │   ├── post-tool.ts      # tool.execute.after handler
│       │   ├── todo-guard.ts     # tool.execute.before handler
│       │   └── compaction.ts     # session.compacting handler
│       └── tools/
│           └── sessions-api.ts   # Custom tool for state/config management
├── agents/
│   ├── context-gathering.md
│   ├── code-review.md
│   ├── logging.md
│   ├── context-refinement.md
│   └── service-documentation.md
├── commands/
│   ├── sessions-state.md
│   ├── sessions-config.md
│   └── sessions-tasks.md
└── package.json                  # Already exists
```

Plus `opencode.json` at repo root to register the plugin and agents.

#### opencode.json Configuration

```json
{
  "plugin": [".opencode/plugins/sessions"],
  "agent": {
    "context-gathering": { ... },
    "code-review": { ... },
    "logging": { ... },
    "context-refinement": { ... },
    "service-documentation": { ... }
  },
  "command": {
    "sessions-state": { "template": "...", "description": "Show/modify sessions state" },
    "sessions-config": { "template": "...", "description": "Show/modify sessions config" },
    "sessions-tasks": { "template": "...", "description": "List/manage tasks" }
  }
}
```

Or agents can be defined as `.opencode/agents/*.md` files with frontmatter.

### Technical Reference Details

#### Key Architectural Decisions

1. **permission.ask for DAIC** (not tool.execute.before): permission.ask can outright deny tool execution before it runs. tool.execute.before can only modify args, not block execution. This is the correct choice for mode enforcement.

2. **system.transform for protocols** (not chat.message): chat.message can modify user message parts but cannot inject system-level instructions. system.transform gives persistent system-level injection that survives across turns.

3. **File-based state** (not in-memory): The state must persist across sessions and be readable by external tools (CLI commands). Using `sessions-state.json` and `sessions-config.json` directly, with the same atomic write + lock pattern from shared_state.js, ported to TypeScript.

4. **Built-in todowrite** (no custom tool needed): OpenCode has a native todowrite tool. The plugin intercepts it via tool.execute.before for validation and tool.execute.after for completion detection.

#### Permission Type Values in OpenCode

Based on the Config type's permission field, the known permission types are:
- `"edit"` -- file editing operations
- `"bash"` -- shell command execution (can have per-pattern sub-permissions)
- `"webfetch"` -- web requests
- `"doom_loop"` -- preventing infinite loops
- `"external_directory"` -- accessing files outside project

For DAIC enforcement, we primarily gate on `"edit"` and `"bash"` (for write-like commands).

#### Protocol File Paths (All Existing, Reusable)

- `/Users/ibar/dotfiles/sessions/protocols/task-creation/task-creation.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-startup/task-startup.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-startup/resume-notes-standard.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-startup/resume-notes-superrepo.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-startup/submodule-management.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-startup/directory-task-startup.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-startup/subtask-startup.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-completion/task-completion.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-completion/commit-standard.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-completion/commit-superrepo.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-completion/commit-style-conventional.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-completion/commit-style-detailed.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-completion/commit-style-simple.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-completion/staging-ask.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-completion/staging-all.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-completion/git-add-warning.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-completion/directory-task-completion.md`
- `/Users/ibar/dotfiles/sessions/protocols/task-completion/subtask-completion.md`
- `/Users/ibar/dotfiles/sessions/protocols/context-compaction/context-compaction.md`

#### State/Config File Paths

- State: `/Users/ibar/dotfiles/sessions/sessions-state.json`
- Config: `/Users/ibar/dotfiles/sessions/sessions-config.json`
- Lock: `/Users/ibar/dotfiles/sessions/sessions-state.lock/`
- Tasks: `/Users/ibar/dotfiles/sessions/tasks/`
- Task template: `/Users/ibar/dotfiles/sessions/tasks/TEMPLATE.md`

#### Task File Frontmatter Schema

```yaml
---
name: [prefix]-[descriptive-name]
branch: feature/[name]|fix/[name]|experiment/[name]|none
status: pending|in-progress|completed|blocked
created: YYYY-MM-DD
submodules: [list of git submodules affected]
---
```

#### Plugin Registration

The `.opencode/package.json` already has `@opencode-ai/plugin` as a dependency. Plugins are registered in `opencode.json` via the `plugin` array field. The plugin entry file must export a default function matching the `Plugin` type signature, or a named export.

Based on the example plugin (`example.js`):
```typescript
import { tool } from "@opencode-ai/plugin/tool";
export const SessionsPlugin: Plugin = async (ctx) => {
  return { /* hooks */ };
};
```

The `opencode.json` `plugin` field takes an array of paths: `[".opencode/plugins/sessions"]` would look for `.opencode/plugins/sessions/index.ts` (or .js).

## User Notes
<!-- Any specific notes or requirements from the developer -->

## Work Log
- [2026-02-16] Task created. Analyzed cc-sessions framework (6 hooks, DAIC modes, 4 protocols, 5 agents, task system). Mapped all features to OpenCode plugin APIs. Consulted Gemini 3 Pro for architecture review. Confirmed OpenCode has full subagent support (no gap). Key architectural decisions: permission.ask for DAIC (not tool.execute.before), system.transform for protocols (not mode switching), built-in todowrite (no custom tool needed).
