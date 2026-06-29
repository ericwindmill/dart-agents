# dart_agents

A minimal tool-calling coding-agent loop for Dart, built on
[`package:ai_primitives`](../ai_primitives).

Modeled on the Python [`mini-swe-agent`](https://github.com/SWE-agent/mini-swe-agent)
project: give the model a bash tool (plus whatever else you register),
and let it explore, edit, and test a codebase across multiple turns
until it stops calling tools or hits a step limit.

This package depends only on `ai_primitives` — bring your own `AI`
implementation to connect a real model provider.

## Usage

```dart
import 'package:ai_primitives/ai_primitives.dart';
import 'package:dart_agents/dart_agents.dart';

final bashTool = Tool(
  name: 'bash',
  description: 'Execute a bash command in the working directory.',
  inputSchema: {
    'type': 'object',
    'properties': {'command': {'type': 'string'}},
    'required': ['command'],
  },
  run: (input) async => runShellCommand(input['command'] as String),
);

final agent = MiniSweAgent(
  ai: myAiProvider, // implements the `AI` interface from ai_primitives
  model: Model('anthropic', 'claude-sonnet-4-6'),
  tools: [bashTool],
);

final result = await agent.run(task: 'Fix the failing test in test/foo_test.dart');

print(result.outputText);
print(result.status); // completed, maxStepsReached, or error
```

## `Agent` is scoped to coding tasks

`Agent`, `BasicAgent`, and `MiniSweAgent` are intentionally narrow: a
single `task: String`, a trajectory of messages, a coding-flavored
default system prompt. They are not a general agent abstraction — if you
need multi-turn chat, non-coding tasks, or agent-to-agent delegation,
build directly on `package:ai_primitives` instead.
