/// Roles in a conversation.
enum Role {
  /// The end user (or calling application) talking to the model.
  user,

  /// The system/developer instruction that sets up the conversation.
  system,

  /// The model's own turn.
  ///
  /// Named `assistant` to match the convention used by OpenAI, Anthropic,
  /// and MCP. Some providers (e.g. Gemini/Genkit) call this role `model`
  /// on the wire; [fromJson] accepts that spelling for interop, but
  /// [toJson] always emits `assistant`.
  assistant,

  /// A tool's response to a tool call made by the assistant.
  tool;

  /// Serialises this role to a JSON-compatible string.
  String toJson() => name;

  /// Deserialises a [Role] from a JSON string.
  ///
  /// Accepts `'model'` as an alias for [assistant] for interop with
  /// providers (e.g. Gemini/Genkit) that use that term on the wire.
  static Role fromJson(String json) => switch (json) {
        'user' => user,
        'system' => system,
        'assistant' || 'model' => assistant,
        'tool' => tool,
        _ => throw FormatException('Unknown Role: $json'),
      };

  @override
  String toString() => name;
}
