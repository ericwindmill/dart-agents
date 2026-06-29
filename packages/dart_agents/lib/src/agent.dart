import 'package:ai_primitives/ai_primitives.dart';
import 'result.dart';

export 'agent_config.dart';
export 'agent_status.dart';
export 'result.dart';

/// Base class for single-task coding agents.
///
/// This is a narrow contract scoped to "send a coding task, run some
/// loop, return a trajectory" — it is not a general-purpose agent
/// abstraction. If you need something more general (multi-turn chat,
/// non-coding tasks, agent-to-agent delegation), build directly on
/// `package:ai_primitives` instead of this class.
///
/// ## Implementations
///
/// - [BasicAgent] — single-turn: sends the task, returns the response.
/// - [MiniSweAgent] — multi-turn: runs a full tool-calling loop.
abstract class Agent {
  const Agent();

  /// The model this agent calls.
  Model get model;

  /// Returns a copy of this agent with [model] replaced.
  ///
  /// Useful for running the same agent across a matrix of models without
  /// mutating a shared instance — keeping [Agent] immutable.
  Agent copyWith({Model? model});

  /// Run the agent.
  ///
  /// [task] is the user's coding task.
  /// [systemMessage] is the system prompt.
  /// [additionalTools] are tools available for this run, appended to any
  ///   tools the agent was constructed with.
  /// [history] is a list of previous messages (e.g. from previous runs)
  ///   that should be prepended to this run's conversation.
  ///
  /// Returns a [Result] with the trajectory, exit status, and usage.
  Future<Result> run({
    required String task,
    String systemMessage,
    List<Tool> additionalTools = const [],
    List<Message> history = const [],
  });
}
