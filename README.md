# dart-agents

Framework-agnostic AI primitives and a minimal coding-agent
implementation for Dart, split into two packages:

- **[`ai_primitives`](packages/ai_primitives)** — `Message`, `Part`
  (`TextPart`, `ToolCallPart`, `ToolResultPart`), `Role`, `Model`,
  `Tool`, `Response`, `Usage`, and the `AI` provider interface. No
  dependency on any model provider SDK or agent framework. JSON shapes
  are designed to map cleanly onto the conventions used by OpenAI,
  Anthropic, and MCP.

- **[`mini_swe_agent`](packages/mini_swe_agent)** — `Agent`,
  `BasicAgent`, and `MiniSweAgent`: a minimal generate-execute
  tool-calling loop for coding tasks, built entirely on
  `ai_primitives`.

Depend on `ai_primitives` alone if you're building your own agent loop,
a chat UI, an MCP/A2A adapter, or anything else that needs a common
vocabulary for messages and tools without committing to a specific
agent framework. Depend on `mini_swe_agent` as well if you want a
ready-made coding-agent loop.

## Working in this repo

This is a [Dart pub workspace](https://dart.dev/tools/pub/workspaces),
managed day-to-day with [Melos](https://melos.invertase.dev). The two
packages link to each other locally via the `workspace:` field in the
root `pubspec.yaml` — no `path:` dependencies, no
`dependency_overrides.yaml`.

Setup:

```bash
dart pub global activate melos
dart pub get   # resolves the whole workspace at once
```

Common tasks, run from the repo root:

```bash
melos run format    # check formatting across every package
melos run analyze   # dart analyze, fatal on infos/warnings
melos run test       # dart test, in every package
melos run check      # format + analyze + test — the pre-publish gate
```

`melos exec -- <command>` runs an arbitrary command in every package if
you need something the scripts above don't cover.

### Versioning and publishing

Versioning and changelog generation are driven by
[Conventional Commits](https://www.conventionalcommits.org/) via
`melos version`. Publishing goes through `melos publish` (dry-run by
default) or the `Publish` GitHub Actions workflow, which is manually
triggered and dry-run by default until the first real release of each
package.
