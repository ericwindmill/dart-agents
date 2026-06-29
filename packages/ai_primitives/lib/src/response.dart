import 'package:equatable/equatable.dart';

import 'message.dart';
import 'parts.dart';
import 'usage.dart';

/// The result of a generation call.
class Response extends Equatable {
  /// The message returned by the model.
  final Message? message;

  /// Token usage for this call.
  final Usage usage;

  /// Why the model stopped generating.
  final String? stopReason;

  const Response({
    this.message,
    this.usage = const Usage.zero(),
    this.stopReason,
  });

  /// Any tool calls the model made in this turn.
  ///
  /// Derived from [message]'s content rather than stored separately, so
  /// it can never drift out of sync with the message it's reporting on.
  List<ToolCallPart> get toolCalls =>
      message?.content.whereType<ToolCallPart>().toList() ?? const [];

  /// Convenience getter for the text content of the response.
  ///
  /// See [Message.text] for how multi-part text is combined.
  String? get text => message?.text;

  @override
  List<Object?> get props => [message, usage, stopReason];
}
