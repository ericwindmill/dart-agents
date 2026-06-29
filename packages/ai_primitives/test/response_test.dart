import 'package:ai_primitives/ai_primitives.dart';
import 'package:test/test.dart';

void main() {
  group('Response.toolCalls', () {
    test('is empty when message is null', () {
      const response = Response();
      expect(response.toolCalls, isEmpty);
    });

    test('derives tool calls from message content', () {
      const response = Response(
        message: Message(
          role: Role.assistant,
          content: [
            TextPart('Let me check.'),
            ToolCallPart(id: '1', name: 'bash', input: {'command': 'ls'}),
            ToolCallPart(id: '2', name: 'bash', input: {'command': 'pwd'}),
          ],
        ),
      );
      expect(response.toolCalls, hasLength(2));
      expect(response.toolCalls.map((c) => c.id), ['1', '2']);
    });

    test('never drifts from message content (no separate field to set)', () {
      const message = Message(
        role: Role.assistant,
        content: [ToolCallPart(id: '1', name: 'bash', input: {})],
      );
      final r1 = Response(message: message);
      final r2 = Response(message: message);
      // Same message in -> same derived tool calls out, always.
      expect(r1.toolCalls, equals(r2.toolCalls));
    });
  });

  group('Response.text', () {
    test('delegates to Message.text', () {
      final response = Response(message: Message.text(Role.assistant, 'hi'));
      expect(response.text, 'hi');
    });
  });

  group('Model', () {
    test('toString formats as provider/version', () {
      const model = Model('anthropic', 'claude-sonnet-4-6');
      expect(model.toString(), 'anthropic/claude-sonnet-4-6');
    });

    test('parse splits on the first slash', () {
      final model = Model.parse('googleai/gemini-2.5-flash');
      expect(model.provider, 'googleai');
      expect(model.version, 'gemini-2.5-flash');
    });

    test('parse throws when there is no slash', () {
      expect(() => Model.parse('no-slash-here'), throwsFormatException);
    });
  });
}
