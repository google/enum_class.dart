// GENERATED CODE - DO NOT MODIFY BY HAND

part of enum_class_generator.source_class;

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class SourceClass
// **************************************************************************

class _$SourceClass extends SourceClass {
  final String name;
  final BuiltList<SourceField> fields;
  final BuiltList<String> constructors;
  final String valuesIdentifier;
  final String valueOfIdentifier;
  final bool usesMixin;
  final String mixinDeclaration;
  _$SourceClass._(
      {this.name,
      this.fields,
      this.constructors,
      this.valuesIdentifier,
      this.valueOfIdentifier,
      this.usesMixin,
      this.mixinDeclaration})
      : super._() {
    if (name == null) throw new ArgumentError('null name');
    if (fields == null) throw new ArgumentError('null fields');
    if (constructors == null) throw new ArgumentError('null constructors');
    if (usesMixin == null) throw new ArgumentError('null usesMixin');
  }
  factory _$SourceClass([updates(SourceClassBuilder b)]) =>
      (new SourceClassBuilder()..update(updates)).build();
  SourceClass rebuild(updates(SourceClassBuilder b)) =>
      (toBuilder()..update(updates)).build();
  _$SourceClassBuilder toBuilder() => new _$SourceClassBuilder()..replace(this);
  bool operator ==(other) {
    if (other is! SourceClass) return false;
    return name == other.name &&
        fields == other.fields &&
        constructors == other.constructors &&
        valuesIdentifier == other.valuesIdentifier &&
        valueOfIdentifier == other.valueOfIdentifier &&
        usesMixin == other.usesMixin &&
        mixinDeclaration == other.mixinDeclaration;
  }

  int get hashCode {
    return hashObjects([
      name,
      fields,
      constructors,
      valuesIdentifier,
      valueOfIdentifier,
      usesMixin,
      mixinDeclaration
    ]);
  }

  String toString() {
    return 'SourceClass {'
        'name=${name.toString()}\n'
        'fields=${fields.toString()}\n'
        'constructors=${constructors.toString()}\n'
        'valuesIdentifier=${valuesIdentifier.toString()}\n'
        'valueOfIdentifier=${valueOfIdentifier.toString()}\n'
        'usesMixin=${usesMixin.toString()}\n'
        'mixinDeclaration=${mixinDeclaration.toString()}\n'
        '}';
  }
}

class _$SourceClassBuilder extends SourceClassBuilder {
  _$SourceClassBuilder() : super._();
  void replace(SourceClass other) {
    super.name = other.name;
    super.fields = other.fields?.toBuilder();
    super.constructors = other.constructors?.toBuilder();
    super.valuesIdentifier = other.valuesIdentifier;
    super.valueOfIdentifier = other.valueOfIdentifier;
    super.usesMixin = other.usesMixin;
    super.mixinDeclaration = other.mixinDeclaration;
  }

  void update(updates(SourceClassBuilder b)) {
    if (updates != null) updates(this);
  }

  SourceClass build() {
    if (name == null) throw new ArgumentError('null name');
    if (fields == null) throw new ArgumentError('null fields');
    if (constructors == null) throw new ArgumentError('null constructors');
    if (usesMixin == null) throw new ArgumentError('null usesMixin');
    return new _$SourceClass._(
        name: name,
        fields: fields?.build(),
        constructors: constructors?.build(),
        valuesIdentifier: valuesIdentifier,
        valueOfIdentifier: valueOfIdentifier,
        usesMixin: usesMixin,
        mixinDeclaration: mixinDeclaration);
  }
}
