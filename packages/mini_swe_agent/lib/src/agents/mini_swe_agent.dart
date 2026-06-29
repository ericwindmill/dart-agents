import 'package:ai_primitives/ai_primitives.dart';

import '../agent.dart';
import 'prompts.dart';

/// An agent that behaves like mini-swe-agent.
///
/// Runs a generate→execute loop: the model receives a coding task and
/// tools (typically bash, read_file, write_file), generates tool calls to
/// explore and modify the codebase, and continues until it produces a
/// text-only response (no tool calls) or hits the step limit.
///
/// This agent is decoupled from any specific AI provider via the [AI]
/// interface from `package:ai_primitives`.
///
/// ## How the loop works
///
/// 1. Build initial messages (system + history + user task).
/// 2. Call `ai.generate()` with `returnToolCalls: true` so we control
///    the loop ourselves.
/// 3. If the model returns tool calls → execute them via the registered
///    tools, append results to the message history, and loop.
/// 4. If the model returns a text-only response → the agent is done.
/// 5. If the step limit is reached → stop and report.
class MiniSweAgent extends Agent {
  /// The AI provider for model calls.
  final AI ai;

  /// The model identifier.
  @override
  final Model model;

  /// Tools to provide to the model.
  final List<Tool> tools;

  /// Configuration for this agent run.
  final AgentConfig config;

  /// Creates a [MiniSweAgent].
  const MiniSweAgent({
    required this.ai,
    required this.model,
    required this.tools,
    this.config = const AgentConfig(),
  });

  @override
  MiniSweAgent copyWith({Model? model}) => MiniSweAgent(
        ai: ai,
        model: model ?? this.model,
        tools: tools,
        config: config,
      );

  /// Run the agent loop.
  ///
  /// [task] is the user's coding task (becomes the first user message).
  /// [systemMessage] is the system prompt (defaults to
  ///   [defaultMiniSweSystemMessage]).
  /// [additionalTools] are appended to [tools] for this run only.
  /// [history] are previous messages (e.g. from previous steps).
  ///
  /// Returns a [Result] with the full trajectory, exit status, and
  /// token usage.
  @override
  Future<Result> run({
    required String task,
    String systemMessage = defaultMiniSweSystemMessage,
    List<Tool> additionalTools = const [],
    List<Message> history = const [],
  }) async {
    final messages = <Message>[
      if (systemMessage.isNotEmpty) Message.text(Role.system, systemMessage),
      ...history,
      Message.text(Role.user, task),
    ];

    final allTools = [...tools, ...additionalTools];
    var usage = const Usage.zero();
    var steps = 0;
    var status = AgentStatus.running;
    String? errorMessage;

    while (status == AgentStatus.running) {
      // Check step limit before generating.
      if (config.maxSteps > 0 && steps >= config.maxSteps) {
        status = AgentStatus.maxStepsReached;
        break;
      }

      try {
        steps++;
        final response = await ai.generate(
          model: model,
          messages: messages,
          tools: allTools,
          returnToolCalls: true,
        );

        // Track token usage.
        usage += response.usage;

        // Append the model's response message to history.
        if (response.message != null) {
          messages.add(response.message!);
        }

        // Check if the model made tool calls.
        final toolCalls = response.toolCalls;
        if (toolCalls.isEmpty) {
          // No tool calls → the model is done.
          status = AgentStatus.completed;
          break;
        }

        // Execute each tool call and build tool result messages.
        final toolResultParts = <ToolResultPart>[];
        for (final toolCall in toolCalls) {
          final result = await _executeTool(toolCall, allTools);
          toolResultParts.add(
            ToolResultPart(
              id: toolCall.id,
              name: toolCall.name,
              output: result.output,
              isError: result.isError,
            ),
          );
        }

        // Append tool results as a single tool-role message.
        messages.add(Message(role: Role.tool, content: toolResultParts));
      } catch (e) {
        status = AgentStatus.error;
        errorMessage = e.toString();
        break;
      }
    }

    return Result(
      messages: messages,
      status: status,
      steps: steps,
      usage: usage,
      error: errorMessage,
    );
  }

  /// Execute a single tool call by finding the matching tool and invoking
  /// it.
  ///
  /// If the tool is not found or execution fails, returns an error result
  /// so the model can see the error and recover — rather than crashing
  /// the whole run over one bad tool call.
  Future<_ToolExecution> _executeTool(
    ToolCallPart toolCall,
    List<Tool> allTools,
  ) async {
    final tool = allTools.where((t) => t.name == toolCall.name).firstOrNull;
    if (tool == null) {
      return _ToolExecution(
        output: 'Error: Unknown tool "${toolCall.name}". '
            'Available tools: ${allTools.map((t) => t.name).join(', ')}',
        isError: true,
      );
    }

    try {
      final output = await tool.run(toolCall.input);
      return _ToolExecution(output: output);
    } catch (e) {
      return _ToolExecution(
        output: 'Error executing tool "${toolCall.name}": $e',
        isError: true,
      );
    }
  }
}

/// Internal result of running a single tool, tracking whether it errored
/// so that gets reflected in the resulting [ToolResultPart.isError].
class _ToolExecution {
  final dynamic output;
  final bool isError;

  _ToolExecution({required this.output, this.isError = false});
}
