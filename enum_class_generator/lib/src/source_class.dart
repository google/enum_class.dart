// Copyright (c) 2016, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library enum_class_generator.source_class;

import 'package:analyzer/dart/element/element.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:enum_class_generator/src/source_field.dart';
import 'package:quiver/iterables.dart';

part 'source_class.g.dart';

abstract class SourceClass implements Built<SourceClass, SourceClassBuilder> {
  String get name;
  BuiltList<SourceField> get fields;
  BuiltList<String> get constructors;
  @nullable
  String get valuesIdentifier;
  @nullable
  String get valueOfIdentifier;
  bool get usesMixin;
  @nullable
  String get mixinDeclaration;

  SourceClass._();
  factory SourceClass([updates(SourceClassBuilder b)]) = _$SourceClass;

  factory SourceClass.fromClassElement(ClassElement classElement) {
    final name = classElement.displayName;
    final mixinElement = classElement.library.getType(name + 'Mixin');
    return new SourceClass((b) => b
      ..name = name
      ..fields.replace(SourceField.fromClassElement(classElement))
      ..constructors.addAll(classElement.constructors
          .map((element) => element.computeNode().toString()))
      ..valuesIdentifier = _getValuesIdentifier(classElement)
      ..valueOfIdentifier = _getValueOfIdentifier(classElement)
      ..usesMixin = mixinElement != null
      ..mixinDeclaration = mixinElement?.computeNode()?.toString());
  }

  static String _getValueOfIdentifier(ClassElement classElement) {
    final getter = classElement.getMethod('valueOf');
    if (getter == null) return null;
    final source = getter.computeNode().toSource();
    final matches = new RegExp(r'static ' +
            classElement.displayName +
            r' valueOf\(String name\) \=\> (\_\$\w+)\(name\)\;')
        .allMatches(source);
    return matches.isEmpty ? null : matches.first.group(1);
  }

  static String _getValuesIdentifier(ClassElement classElement) {
    final getter = classElement.getGetter('values');
    if (getter == null) return null;
    final source = getter.computeNode().toSource();
    final matches = new RegExp(r'static BuiltSet<' +
            classElement.displayName +
            r'> get values => (_\$\w+)\;')
        .allMatches(source);
    return matches.isEmpty ? null : matches.first.group(1);
  }

  static bool isMissingImportFor(ClassElement classElement) {
    return classElement.supertype.displayName != 'EnumClass' &&
        classElement
            .computeNode()
            .toSource()
            .contains('class ${classElement.displayName} extends EnumClass');
  }

  static bool needsEnumClass(ClassElement classElement) {
    return classElement.supertype.displayName == 'EnumClass';
  }

  Iterable<String> get identifiers {
    return concat([
      [valuesIdentifier, valueOfIdentifier],
      fields.map((field) => field.generatedIdentifier)
    ]);
  }

  Iterable<String> computeErrors() {
    return concat([
      _checkFields(),
      _checkConstructor(),
      _checkValuesGetter(),
      _checkValueOf(),
      _checkMixin()
    ]).toList();
  }

  Iterable<String> _checkFields() {
    return concat(fields.map((field) => field.errors));
  }

  Iterable<String> _checkConstructor() {
    final expectedCode = 'const $name._(String name) : super(name);';
    return constructors.length == 1 && constructors.single == expectedCode
        ? <String>[]
        : <String>['Have exactly one constructor: $expectedCode'];
  }

  Iterable<String> _checkValuesGetter() {
    final result = <String>[];
    if (valuesIdentifier == null) {
      result.add('Add getter: static BuiltSet<$name> get values => _\$values');
    }
    return result;
  }

  Iterable<String> _checkValueOf() {
    final result = <String>[];
    if (valueOfIdentifier == null) {
      result.add('Add method: '
          'static $name valueOf(String name) => _\$valueOf(name)');
    }
    return result;
  }

  Iterable<String> _checkMixin() {
    if (usesMixin) {
      final expectedCode =
          'abstract class ${name}Mixin = Object with _\$${name}Mixin;';
      if (!mixinDeclaration.contains(expectedCode)) {
        return ['Remove mixin or declare using exactly: $expectedCode'];
      }
    }
    return [];
  }

  String generateCode() {
    final result = new StringBuffer();

    for (final field in fields) {
      result.writeln('const $name ${field.generatedIdentifier} = '
          'const $name._(\'${field.name}\');');
    }

    result.writeln('');

    result.writeln('$name $valueOfIdentifier(String name) {'
        'switch (name) {');
    for (final field in fields) {
      result.writeln(
          'case \'${field.name}\': return ${field.generatedIdentifier};');
    }
    result.writeln('default: throw new ArgumentError(name);');
    result.writeln('}}');

    result.writeln('');

    result.writeln('final BuiltSet<$name> $valuesIdentifier ='
        'new BuiltSet<$name>(const [');
    for (final field in fields) {
      result.writeln('${field.generatedIdentifier},');
    }
    result.writeln(']);');

    if (usesMixin) {
      result.write(_generateMixin());
    }

    return result.toString();
  }

  String _generateMixin() {
    final result = new StringBuffer();

    result
      ..writeln('class _\$${name}Meta {')
      ..writeln('const _\$${name}Meta();');
    for (final field in fields) {
      result
          .writeln('$name get ${field.name} => ${field.generatedIdentifier};');
    }
    result
      ..writeln('$name valueOf(String name) => $valueOfIdentifier(name);')
      ..writeln('BuiltSet<$name> get values => $valuesIdentifier;')
      ..writeln('}')
      ..writeln('abstract class _\$${name}Mixin {')
      ..writeln('_\$${name}Meta get $name => const _\$${name}Meta();')
      ..writeln('}');

    return result.toString();
  }
}

abstract class SourceClassBuilder
    implements Builder<SourceClass, SourceClassBuilder> {
  SourceClassBuilder._();
  factory SourceClassBuilder() = _$SourceClassBuilder;

  String name;
  ListBuilder<SourceField> fields = new ListBuilder<SourceField>();
  ListBuilder<String> constructors = new ListBuilder<String>();
  String valuesIdentifier;
  String valueOfIdentifier;
  bool usesMixin;
  String mixinDeclaration;
}
