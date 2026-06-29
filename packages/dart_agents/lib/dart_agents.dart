/// A minimal tool-calling coding-agent loop for Dart.
///
/// Built entirely on `package:ai_primitives` — provides [Agent],
/// [AgentConfig], [AgentStatus], and [Result] as the foundation, plus two
/// ready-to-use implementations:
///
/// - [BasicAgent] — single-turn: sends the task, returns the response.
/// - [MiniSweAgent] — multi-turn: runs a full generate→execute
///   tool-calling loop, modeled on the Python `mini-swe-agent` project.
///
/// For the underlying AI primitives ([Message], [Tool], [Role], etc.),
/// import `package:ai_primitives/ai_primitives.dart`.
library;

export 'src/agent.dart';
export 'src/agent_config.dart';
export 'src/agent_status.dart';
export 'src/result.dart';

// Implementations
export 'src/agents/basic_agent.dart';
export 'src/agents/mini_swe_agent.dart';
export 'src/agents/prompts.dart';
