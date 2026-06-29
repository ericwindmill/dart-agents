import 'message.dart';
import 'model.dart';
import 'response.dart';
import 'tool.dart';

/// Interface for an AI provider.
///
/// Implement this to adapt any model provider's SDK to the primitives in
/// this package. Nothing in `ai_primitives` depends on a specific
/// implementation of [AI] — agent implementations built on top of these
/// primitives should depend only on this interface.
abstract class AI {
  /// Generate a response for the given [messages].
  ///
  /// [model] identifies which model to use.
  /// [tools] are the tools available to the model.
  /// [returnToolCalls] if true, the provider should return tool calls in
  /// the response rather than executing them itself (if it's capable of
  /// doing so) — set this when the caller wants to run its own
  /// generate-execute loop rather than delegate tool execution to the
  /// provider.
  Future<Response> generate({
    required Model model,
    required List<Message> messages,
    List<Tool> tools = const [],
    bool returnToolCalls = false,
  });
}
