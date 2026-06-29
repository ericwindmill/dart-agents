import 'package:equatable/equatable.dart';

/// A model identifier consisting of a provider and version.
///
/// The string form is `$provider/$version`, matching common model
/// reference formats (e.g. `anthropic/claude-sonnet-4-6`,
/// `googleai/gemini-2.5-flash`).
class Model extends Equatable {
  final String provider;
  final String version;

  const Model(this.provider, this.version);

  /// Parses a `provider/version` string into a [Model].
  factory Model.parse(String id) {
    final i = id.indexOf('/');
    if (i < 0) {
      throw FormatException('Expected "provider/version", got "$id"');
    }
    return Model(id.substring(0, i), id.substring(i + 1));
  }

  @override
  List<Object?> get props => [provider, version];

  @override
  String toString() => '$provider/$version';
}
