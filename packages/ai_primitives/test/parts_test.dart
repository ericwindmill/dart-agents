import 'package:ai_primitives/ai_primitives.dart';
import 'package:test/test.dart';

void main() {
  group('TextPart', () {
    test('round-trips through JSON', () {
      const part = TextPart('hello');
      final json = part.toJson();
      expect(json, {'type': 'text', 'text': 'hello'});
      expect(Part.fromJson(json), equals(part));
    });
  });

  group('ToolCallPart', () {
    test('round-trips through JSON', () {
      const part = ToolCallPart(
        id: 'call_1',
        name: 'bash',
        input: {'command': 'ls'},
      );
      final json = part.toJson();
      expect(json, {
        'type': 'tool_call',
        'id': 'call_1',
        'name': 'bash',
        'input': {'command': 'ls'},
      });
      expect(Part.fromJson(json), equals(part));
    });
  });

  group('ToolResultPart', () {
    test('round-trips through JSON', () {
      const part = ToolResultPart(id: 'call_1', name: 'bash', output: 'a.txt');
      final json = part.toJson();
      expect(json, {
        'type': 'tool_result',
        'id': 'call_1',
        'name': 'bash',
        'output': 'a.txt',
      });
      expect(Part.fromJson(json), equals(part));
    });

    test('omits isError when false but includes it when true', () {
      const ok = ToolResultPart(id: '1', name: 't', output: 'fine');
      expect(ok.toJson().containsKey('isError'), isFalse);

      const err = ToolResultPart(
        id: '1',
        name: 't',
        output: 'boom',
        isError: true,
      );
      expect(err.toJson()['isError'], true);
      expect(Part.fromJson(err.toJson()), equals(err));
    });
  });

  group('Part.fromJson', () {
    test('throws on unknown type', () {
      expect(
        () => Part.fromJson({'type': 'mystery'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
