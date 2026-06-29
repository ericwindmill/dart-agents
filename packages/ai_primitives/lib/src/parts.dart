import 'package:equatable/equatable.dart';

/// Base class for message parts.
///
/// A [Part] is one piece of a [Message]'s content. Every part type
/// serialises with a `type` discriminator field, matching the convention
/// used by Anthropic's content blocks and MCP's content items, so the
/// JSON shape is mechanically convertible to/from those formats.
abstract class Part extends Equatable {
  const Part();

  /// Convenience factory for a text part.
  factory Part.text(String text) => TextPart(text);

  /// Serialises this part to a JSON-compatible map.
  ///
  /// Always includes a `'type'` discriminator field.
  Map<String, dynamic> toJson();

  /// Deserialises a [Part] from a JSON map, dispatching on `json['type']`.
  factory Part.fromJson(Map<String, dynamic> json) => switch (json['type']) {
        'text' => TextPart.fromJson(json),
        'tool_call' => ToolCallPart.fromJson(json),
        'tool_result' => ToolResultPart.fromJson(json),
        _ => throw FormatException('Unknown Part type: ${json['type']}'),
      };
}

/// A text part of a message.
class TextPart extends Part {
  final String text;
  const TextPart(this.text);

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};

  /// Deserialises a [TextPart] from a JSON map.
  factory TextPart.fromJson(Map<String, dynamic> json) =>
      TextPart(json['text'] as String);

  @override
  List<Object?> get props => [text];

  @override
  String toString() => 'Text: $text';
}

/// A request from the model to call a tool.
///
/// [id] correlates this call with the [ToolResultPart] that answers it —
/// the same role played by `id`/`tool_call_id` in OpenAI and Anthropic's
/// APIs, and by the request id in MCP's `tools/call`.
class ToolCallPart extends Part {
  /// Identifier for this call, used to match it to its [ToolResultPart].
  final String id;

  /// The name of the tool being called.
  final String name;

  /// The arguments for the call, matching the tool's input schema.
  final Map<String, dynamic> input;

  const ToolCallPart({
    required this.id,
    required this.name,
    required this.input,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'tool_call',
        'id': id,
        'name': name,
        'input': input,
      };

  /// Deserialises a [ToolCallPart] from a JSON map.
  factory ToolCallPart.fromJson(Map<String, dynamic> json) => ToolCallPart(
        id: json['id'] as String,
        name: json['name'] as String,
        input: json['input'] as Map<String, dynamic>,
      );

  @override
  List<Object?> get props => [id, name, input];

  @override
  String toString() => 'ToolCall($id): $name($input)';
}

/// The result of executing a tool call.
///
/// [id] must match the [ToolCallPart.id] of the call this answers.
class ToolResultPart extends Part {
  /// The id of the [ToolCallPart] this is a result for.
  final String id;

  /// The name of the tool that was called.
  final String name;

  /// The tool's output. Anything JSON-encodable, or a [String] error
  /// message if [isError] is `true`.
  final dynamic output;

  /// Whether [output] represents an error from the tool, rather than a
  /// successful result. Surfacing this lets the model distinguish "the
  /// tool ran and returned this" from "the tool failed."
  final bool isError;

  const ToolResultPart({
    required this.id,
    required this.name,
    required this.output,
    this.isError = false,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'tool_result',
        'id': id,
        'name': name,
        'output': output,
        if (isError) 'isError': true,
      };

  /// Deserialises a [ToolResultPart] from a JSON map.
  factory ToolResultPart.fromJson(Map<String, dynamic> json) => ToolResultPart(
        id: json['id'] as String,
        name: json['name'] as String,
        output: json['output'],
        isError: json['isError'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, name, output, isError];

  @override
  String toString() => 'ToolResult($id): $name -> $output';
}
