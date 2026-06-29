import 'package:equatable/equatable.dart';

/// Token usage for a single generation call.
///
/// Field names match Anthropic's `usage` object (`input_tokens`,
/// `output_tokens`) rather than OpenAI's (`prompt_tokens`,
/// `completion_tokens`) — same concepts, different vendor's naming
/// convention, picked since it reads more clearly outside an API context.
class Usage extends Equatable {
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;

  const Usage({
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.totalTokens = 0,
  });

  const Usage.zero()
      : inputTokens = 0,
        outputTokens = 0,
        totalTokens = 0;

  Usage operator +(Usage other) => Usage(
        inputTokens: inputTokens + other.inputTokens,
        outputTokens: outputTokens + other.outputTokens,
        totalTokens: totalTokens + other.totalTokens,
      );

  @override
  List<Object?> get props => [inputTokens, outputTokens, totalTokens];
}
