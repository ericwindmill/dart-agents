import 'package:ai_primitives/ai_primitives.dart';
import 'package:test/test.dart';

void main() {
  group('Message.text', () {
    test('returns null when there are no text parts', () {
      const message = Message(
        role: Role.assistant,
        content: [ToolCallPart(id: '1', name: 'bash', input: {})],
      );
      expect(message.text, isNull);
    });

    test('returns the text for a single text part', () {
      final message = Message.text(Role.user, 'hello');
      expect(message.text, 'hello');
    });

    test(
      'concatenates multiple text parts rather than returning only the first',
      () {
        const message = Message(
          role: Role.assistant,
          content: [TextPart('Running command. '), TextPart('Done.')],
        );
        expect(message.text, 'Running command. Done.');
      },
    );

    test('ignores non-text parts when concatenating', () {
      const message = Message(
        role: Role.assistant,
        content: [
          TextPart('Let me check. '),
          ToolCallPart(id: '1', name: 'bash', input: {}),
          TextPart('Done.'),
        ],
      );
      expect(message.text, 'Let me check. Done.');
    });
  });

  group('Message JSON', () {
    test('round-trips a multi-part message', () {
      const message = Message(
        role: Role.assistant,
        content: [
          TextPart('Checking files.'),
          ToolCallPart(id: 'c1', name: 'ls', input: {'path': '.'}),
        ],
      );
      final roundTripped = Message.fromJson(message.toJson());
      expect(roundTripped, equals(message));
    });
  });

  group('Role', () {
    test('toJson always emits "assistant"', () {
      expect(Role.assistant.toJson(), 'assistant');
    });

    test('fromJson accepts "model" as an alias for assistant', () {
      expect(Role.fromJson('model'), Role.assistant);
      expect(Role.fromJson('assistant'), Role.assistant);
    });

    test('fromJson throws on unknown role', () {
      expect(
        () => Role.fromJson('narrator'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
