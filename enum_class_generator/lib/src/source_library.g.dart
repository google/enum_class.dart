// GENERATED CODE - DO NOT MODIFY BY HAND

part of enum_class_generator.source_library;

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class SourceLibrary
// **************************************************************************

class _$SourceLibrary extends SourceLibrary {
  final String name;
  final String fileName;
  final String source;
  final BuiltList<SourceClass> classes;

  _$SourceLibrary._({this.name, this.fileName, this.source, this.classes})
      : super._() {
    if (name == null) throw new ArgumentError.notNull('name');
    if (fileName == null) throw new ArgumentError.notNull('fileName');
    if (source == null) throw new ArgumentError.notNull('source');
    if (classes == null) throw new ArgumentError.notNull('classes');
  }

  factory _$SourceLibrary([updates(SourceLibraryBuilder b)]) =>
      (new SourceLibraryBuilder()..update(updates)).build();

  SourceLibrary rebuild(updates(SourceLibraryBuilder b)) =>
      (toBuilder()..update(updates)).build();

  _$SourceLibraryBuilder toBuilder() =>
      new _$SourceLibraryBuilder()..replace(this);

  bool operator ==(other) {
    if (other is! SourceLibrary) return false;
    return name == other.name &&
        fileName == other.fileName &&
        source == other.source &&
        classes == other.classes;
  }

  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, name.hashCode), fileName.hashCode), source.hashCode),
        classes.hashCode));
  }

  String toString() {
    return 'SourceLibrary {'
        'name=${name.toString()},\n'
        'fileName=${fileName.toString()},\n'
        'source=${source.toString()},\n'
        'classes=${classes.toString()},\n'
        '}';
  }
}

class _$SourceLibraryBuilder extends SourceLibraryBuilder {
  _$SourceLibraryBuilder() : super._();
  void replace(SourceLibrary other) {
    super.name = other.name;
    super.fileName = other.fileName;
    super.source = other.source;
    super.classes = other.classes?.toBuilder();
  }

  void update(updates(SourceLibraryBuilder b)) {
    if (updates != null) updates(this);
  }

  SourceLibrary build() {
    return new _$SourceLibrary._(
        name: name,
        fileName: fileName,
        source: source,
        classes: classes?.build());
  }
}
