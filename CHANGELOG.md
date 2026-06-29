# Changelog

## Unreleased

Adopted Dart pub workspaces + Melos for repo-wide tooling:

- Added a root `pubspec.yaml` with a `workspace:` field listing both
  packages, and a `melos:` section defining `format`, `analyze`, `test`,
  and `check` scripts.
- Both packages now use `resolution: workspace` instead of a `path:`
  dependency for `ai_primitives` — `mini_swe_agent` depends on
  `ai_primitives: ^0.1.0` exactly as it will once published, but pub
  resolves it from disk while both are in this workspace.
- Removed `publish_to: none` from both packages, since they're intended
  to actually be published.
- Added `.github/workflows/ci.yml` (format/analyze/test on every push
  and PR) and `.github/workflows/publish.yml` (manual, dry-run-by-default
  versioning and publishing via `melos publish`).

Split the single `dart_agent_primitives` package into two:

- `ai_primitives` — the framework-agnostic core types, with no
  dependency on any agent framework. Aligned naming/JSON shapes with
  OpenAI/Anthropic/MCP conventions:
  - `Role.model` renamed to `Role.assistant` (`fromJson` still accepts
    `'model'` as an alias for interop).
  - `ToolRequestPart`/`ToolResponsePart` renamed to `ToolCallPart`/
    `ToolResultPart`; their `ref` field renamed to `id`; JSON shape
    flattened with a `type` discriminator instead of a wrapper key.
  - `ToolResultPart` gained `isError`, so tool failures are
    distinguishable from successful string output (matches MCP's
    `CallToolResult.isError`).
  - `Response.toolRequests` (a separately-stored field that could drift
    from `message.content`) replaced with a derived `toolCalls` getter.
  - `Message.text` now concatenates all text parts instead of returning
    only the first.
  - `AI.generate`'s `model` parameter changed from `String` to `Model`;
    `returnToolRequests` renamed to `returnToolCalls`.
  - Added `Model.parse`.

- `mini_swe_agent` — `Agent`, `AgentConfig`, `AgentStatus`, `Result`,
  `BasicAgent`, and `MiniSweAgent`, depending on `ai_primitives`. Doc
  comments now make clear this is a coding-agent-scoped loop, not a
  general agent abstraction.
  - `BasicAgent` and `MiniSweAgent` now build the system message before
    `history` rather than after (previous order put the system prompt
    in the middle of the conversation).
  - `BasicAgent` now has its own default system prompt instead of
    sharing `MiniSweAgent`'s bash-iteration prompt.

## 25 June, 2026

Initial commit.

Adds ai primitive classes, and implementations of basic-agent and minisweagent.
