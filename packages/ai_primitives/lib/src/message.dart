import 'package:equatable/equatable.dart';

import 'parts.dart';
import 'role.dart';

/// A single message in a conversation history.
class Message extends Equatable {
  final Role role;
  final List<Part> content;

  const Message({required this.role, required this.content});

  /// Convenience constructor for a simple text message.
  factory Message.text(Role role, String text) =>
      Message(role: role, content: [TextPart(text)]);

  /// Deserialises a [Message] from a JSON map.
  factory Message.fromJson(Map<String, dynamic> json) => Message(
        role: Role.fromJson(json['role'] as String),
        content: (json['content'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(Part.fromJson)
            .toList(),
      );

  /// The concatenation of all [TextPart]s in [content], in order,
  /// joined with no separator.
  ///
  /// Returns `null` if [content] has no text parts at all. Most messages
  /// have a single text part, in which case this is just that part's
  /// text — but if a message mixes multiple text parts (e.g. text
  /// before and after a tool call), this concatenates all of them rather
  /// than silently returning only the first.
  String? get text {
    final parts = content.whereType<TextPart>();
    if (parts.isEmpty) return null;
    return parts.map((p) => p.text).join();
  }

  /// Serialises this message to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'role': role.toJson(),
        'content': content.map((p) => p.toJson()).toList(),
      };

  @override
  List<Object?> get props => [role, content];
}
