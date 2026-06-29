/// Framework-agnostic AI primitives for Dart.
///
/// Provides the core types for AI/LLM interactions — [Message], [Part]
/// (and its subtypes [TextPart], [ToolCallPart], [ToolResultPart]),
/// [Role], [Model], [Tool], [Response], [Usage], and the [AI] provider
/// interface — with no dependency on any specific model provider SDK or
/// agent framework.
///
/// JSON shapes are designed to be mechanically convertible to/from the
/// conventions used by OpenAI, Anthropic, and MCP (a `type` discriminator
/// on content parts, `id`-based correlation between tool calls and
/// results, JSON Schema for tool parameters) — so adapting these types to
/// a specific provider or protocol should mostly be relabelling, not
/// reshaping.
///
/// For agent implementations built on top of these primitives, see e.g.
/// `package:dart_agents`.
library;

export 'src/ai.dart';
export 'src/message.dart';
export 'src/model.dart';
export 'src/parts.dart';
export 'src/response.dart';
export 'src/role.dart';
export 'src/tool.dart';
export 'src/usage.dart';
