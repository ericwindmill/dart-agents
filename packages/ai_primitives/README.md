# ai_primitives

Framework-agnostic data types for AI/LLM interactions in Dart.

This package has no dependency on any model provider SDK or agent
framework — it only defines the shapes: [`Message`], [`Part`] (and its
subtypes [`TextPart`], [`ToolCallPart`], [`ToolResultPart`]), [`Role`],
[`Model`], [`Tool`], [`Response`], [`Usage`], and the [`AI`] provider
interface.

## Why these shapes

JSON Schema is the de facto standard for describing tool/function
parameters across OpenAI, Anthropic, Gemini, and MCP — so `Tool.inputSchema`
is plain `Map<String, dynamic>` JSON Schema, not a custom schema type.

Content parts use a `type` discriminator and `id`-based correlation
between tool calls and their results, matching the conventions used by
Anthropic's content blocks, OpenAI's `tool_calls`, and MCP's
`tools/call` — so converting a [`Part`] to/from any of those formats is
mostly relabelling fields, not reshaping data.

This package does **not** implement a provider client, an agent loop, or
MCP/A2A support — see [`AI`] for the seam where you plug in a real
provider, and `package:dart_agents` for an example tool-calling loop
built on top of these primitives.

## Usage

```dart
import 'package:ai_primitives/ai_primitives.dart';

final tool = Tool(
  name: 'get_weather',
  description: 'Get the current weather for a city.',
  inputSchema: {
    'type': 'object',
    'properties': {'city': {'type': 'string'}},
    'required': ['city'],
  },
  run: (input) async => 'Sunny in ${input['city']}',
);

final messages = [
  Message.text(Role.system, 'You are a helpful assistant.'),
  Message.text(Role.user, 'What is the weather in Tokyo?'),
];
```

## Implementing `AI`

Adapt any provider's SDK by implementing the `AI` interface:

```dart
class MyProviderAI implements AI {
  @override
  Future<Response> generate({
    required Model model,
    required List<Message> messages,
    List<Tool> tools = const [],
    bool returnToolCalls = false,
  }) async {
    // Call your provider's SDK, map its response into a Response.
  }
}
```
