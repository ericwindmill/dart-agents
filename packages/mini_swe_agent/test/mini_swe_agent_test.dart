import 'package:ai_primitives/ai_primitives.dart';
import 'package:mini_swe_agent/mini_swe_agent.dart';
import 'package:test/test.dart';

/// A fake [AI] that replays a scripted sequence of responses, one per
/// call to [generate]. Lets tests drive [MiniSweAgent]'s loop without a
/// real model.
class _ScriptedAI implements AI {
  final List<Response> script;
  int _calls = 0;

  _ScriptedAI(this.script);

  int get callCount => _calls;

  @override
  Future<Response> generate({
    required Model model,
    required List<Message> messages,
    List<Tool> tools = const [],
    bool returnToolCalls = false,
  }) async {
    final response = script[_calls];
    _calls++;
    return response;
  }
}

void main() {
  const model = Model('test', 'fake-1');

  group('MiniSweAgent', () {
    test(
      'completes in one step when the model returns no tool calls',
      () async {
        final ai = _ScriptedAI([
          Response(message: Message.text(Role.assistant, 'All done.')),
        ]);
        final agent = MiniSweAgent(ai: ai, model: model, tools: const []);

        final result = await agent.run(task: 'do nothing');

        expect(result.status, AgentStatus.completed);
        expect(result.steps, 1);
        expect(result.outputText, 'All done.');
      },
    );

    test(
      'runs the tool, feeds the result back, and finishes on the next step',
      () async {
        var ran = false;
        final tool = Tool(
          name: 'bash',
          description: 'runs a command',
          run: (input) async {
            ran = true;
            return 'file1.txt\nfile2.txt';
          },
        );

        final ai = _ScriptedAI([
          Response(
            message: const Message(
              role: Role.assistant,
              content: [
                ToolCallPart(id: 'c1', name: 'bash', input: {'command': 'ls'}),
              ],
            ),
          ),
          Response(message: Message.text(Role.assistant, 'Found two files.')),
        ]);

        final agent = MiniSweAgent(ai: ai, model: model, tools: [tool]);
        final result = await agent.run(task: 'list files');

        expect(ran, isTrue);
        expect(result.status, AgentStatus.completed);
        expect(result.steps, 2);
        expect(result.outputText, 'Found two files.');

        // The tool-result message should carry the matching id and the
        // tool's actual output.
        final toolResultMessage = result.messages.firstWhere(
          (m) => m.role == Role.tool,
        );
        final toolResult = toolResultMessage.content.first as ToolResultPart;
        expect(toolResult.id, 'c1');
        expect(toolResult.output, 'file1.txt\nfile2.txt');
        expect(toolResult.isError, isFalse);
      },
    );

    test('surfaces an unknown tool as an error result, not a crash', () async {
      final ai = _ScriptedAI([
        Response(
          message: const Message(
            role: Role.assistant,
            content: [ToolCallPart(id: 'c1', name: 'nonexistent', input: {})],
          ),
        ),
        Response(message: Message.text(Role.assistant, 'Recovered.')),
      ]);

      final agent = MiniSweAgent(ai: ai, model: model, tools: const []);
      final result = await agent.run(task: 'call a missing tool');

      final toolResultMessage = result.messages.firstWhere(
        (m) => m.role == Role.tool,
      );
      final toolResult = toolResultMessage.content.first as ToolResultPart;
      expect(toolResult.isError, isTrue);
      expect(toolResult.output, contains('Unknown tool'));
      // The loop should continue (and not crash the run) after the error.
      expect(result.status, AgentStatus.completed);
    });

    test(
      'stops with maxStepsReached when the model never stops calling tools',
      () async {
        final tool = Tool(
          name: 'bash',
          description: 'runs a command',
          run: (input) async => 'ok',
        );
        // Every call returns another tool call -> would loop forever
        // without the step limit.
        final ai = _ScriptedAI(
          List.generate(
            10,
            (_) => Response(
              message: const Message(
                role: Role.assistant,
                content: [
                  ToolCallPart(id: 'c1', name: 'bash', input: {'command': 'x'}),
                ],
              ),
            ),
          ),
        );

        final agent = MiniSweAgent(
          ai: ai,
          model: model,
          tools: [tool],
          config: const AgentConfig(maxSteps: 3),
        );
        final result = await agent.run(task: 'loop forever');

        expect(result.status, AgentStatus.maxStepsReached);
        expect(result.steps, 3);
      },
    );

    test('copyWith replaces the model without mutating the original', () {
      final ai = _ScriptedAI(const []);
      final original = MiniSweAgent(ai: ai, model: model, tools: const []);
      final copy = original.copyWith(model: const Model('test', 'fake-2'));

      expect(original.model, model);
      expect(copy.model, const Model('test', 'fake-2'));
    });
  });
}
