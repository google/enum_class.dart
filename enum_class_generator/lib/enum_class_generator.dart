// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library enum_class_generator;

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:quiver/iterables.dart' show concat;
import 'package:source_gen/source_gen.dart';

/// Generator for Enum Classes.
///
/// See https://github.com/google/enum_class.dart/tree/master/example for how
/// to use it.
class EnumClassGenerator extends Generator {
  Set<String> _usedGeneratedIdentifiers = new Set<String>();

  @override
  Future<String> generate(Element element, BuildStep buildStep) async {
    if (element is! ClassElement) {
      return null;
    }
    final classElement = element as ClassElement;
    final enumName = classElement.displayName;

    if (classElement.supertype.displayName != 'EnumClass') {
      // Maybe they're trying to use EnumClass but forgot to import the library.
      if (classElement
          .computeNode()
          .toSource()
          .contains('class ${classElement.displayName} extends EnumClass')) {
        throw new InvalidGenerationSourceError(
            'Please make changes to use EnumClass.',
            todo:
                "Import EnumClass: import 'package:enum_class/enum_class.dart';");
      } else {
        return null;
      }
    }

    final libraryName = classElement.library.displayName;
    final fields = _getApplicableFields(classElement);
    final errors = concat([
      _checkPart(classElement),
      _checkFields(libraryName, fields),
      _checkConstructor(classElement),
      _checkValuesGetter(libraryName, classElement),
      _checkValueOf(libraryName, classElement)
    ]).toList();

    final mixinElement = classElement.library.getType(enumName + 'Mixin');
    final shouldGenerateMixin = mixinElement != null;
    if (shouldGenerateMixin) {
      final expectedCode =
          'abstract class ${enumName}Mixin = Object with _\$${enumName}Mixin;';
      if (mixinElement.computeNode().toString() != expectedCode) {
        errors.add('Mixin: $expectedCode');
      }
    }

    if (errors.isNotEmpty) {
      throw new InvalidGenerationSourceError(
          'Please make changes to use EnumClass.',
          todo: errors.join(' '));
    }

    return _generateCode(classElement, enumName, fields, shouldGenerateMixin);
  }

  Iterable<String> _checkPart(ClassElement classElement) {
    final fileName =
        classElement.library.source.shortName.replaceAll('.dart', '');
    final expectedCode = "part '$fileName.g.dart';";
    final alternativeExpectedCode = 'part "$fileName.g.dart";';
    final source = classElement.library.source.contents.data;
    return source.contains(expectedCode) ||
            source.contains(alternativeExpectedCode)
        ? <String>[]
        : <String>['Import generated part: $expectedCode'];
  }

  Iterable<FieldElement> _getApplicableFields(ClassElement classElement) {
    final enumName = classElement.displayName;
    final result = <FieldElement>[];
    for (final field in classElement.fields) {
      final type = field.getter.returnType.displayName;
      if (!field.isSynthetic && (type == enumName || type == 'dynamic')) {
        result.add(field);
      }
    }
    return result;
  }

  Iterable<String> _checkFields(
      String libraryName, Iterable<FieldElement> fields) {
    final result = <String>[];
    for (final field in fields) {
      final fieldName = field.displayName;
      if (field.getter.returnType.displayName == 'dynamic') {
        result.add('Specify a type for field "$fieldName".');
        continue;
      } else if (!field.isConst && !field.isStatic) {
        result.add('Make field "$fieldName" static const.');
        continue;
      } else if (!field.isConst) {
        result.add('Make field "$fieldName" const.');
        continue;
      }

      if (!field.computeNode().toString().startsWith('$fieldName = _\$')) {
        result
            .add('Initialize field "$fieldName" with a value starting "_\$".');
      }

      final identifier = _getGeneratedIdentifier(field);
      result.addAll(
          _checkAndRegisterGeneratedIdentifier(libraryName, identifier));
    }
    return result;
  }

  Iterable<String> _checkConstructor(ClassElement classElement) {
    final enumName = classElement.displayName;
    final expectedCode = 'const $enumName._(String name) : super(name);';
    return classElement.constructors.length == 1 &&
        classElement.constructors.single.computeNode().toString() ==
            expectedCode ? <String>[] : <String>['Constructor: $expectedCode'];
  }

  Iterable<String> _checkValuesGetter(
      String libraryName, ClassElement classElement) {
    // TODO(davidmorgan): do this without reading the whole source.
    final enumName = classElement.displayName;
    final valuesIdentifier =
        _getValuesIdentifier(classElement.source.contents.data, enumName);
    final result = <String>[];
    if (valuesIdentifier == null) {
      result.add('Getter: static BuiltSet<$enumName> get values => _\$values');
    } else {
      result.addAll(
          _checkAndRegisterGeneratedIdentifier(libraryName, valuesIdentifier));
    }
    return result;
  }

  Iterable<String> _checkValueOf(
      String libraryName, ClassElement classElement) {
    // TODO(davidmorgan): do this without reading the whole source.
    final enumName = classElement.displayName;

    final valueOfIdentifier =
        _getValueOfIdentifier(classElement.source.contents.data, enumName);

    final result = <String>[];
    if (valueOfIdentifier == null) {
      result.add(
          'Method: static $enumName valueOf(String name) => _\$valueOf(name)');
    } else {
      result.addAll(
          _checkAndRegisterGeneratedIdentifier(libraryName, valueOfIdentifier));
    }
    return result;
  }

  Iterable<String> _checkAndRegisterGeneratedIdentifier(
      String libraryName, String identifier) {
    final result = <String>[];
    final scopedIdentifier = '$libraryName.$identifier';
    if (_usedGeneratedIdentifiers.contains(scopedIdentifier)) {
      result
          .add('Generated identifier "_\$$identifier" is used multiple times in'
              ' $libraryName, change to something else.');
    } else {
      _usedGeneratedIdentifiers.add(scopedIdentifier);
    }
    return result;
  }

  String _generateCode(ClassElement classElement, String enumName,
      Iterable<FieldElement> fields, bool generateMixin) {
    final result = new StringBuffer();

    for (final field in fields) {
      final fieldName = field.displayName;
      result.writeln('const $enumName _\$${_getGeneratedIdentifier(field)} = '
          'const $enumName._(\'$fieldName\');');
    }

    result.writeln('');

    final valueOf =
        _getValueOfIdentifier(classElement.source.contents.data, enumName);
    result.writeln('$enumName _\$$valueOf(String name) {'
        'switch (name) {');
    for (final field in fields) {
      final fieldName = field.displayName;
      result.writeln(
          'case \'$fieldName\': return _\$${_getGeneratedIdentifier(field)};');
    }
    result.writeln('default: throw new ArgumentError(name);');
    result.writeln('}}');

    result.writeln('');

    final values =
        _getValuesIdentifier(classElement.source.contents.data, enumName);
    result.writeln('final BuiltSet<$enumName> _\$$values ='
        'new BuiltSet<$enumName>(const [');
    for (final field in fields) {
      result.writeln('_\$${_getGeneratedIdentifier(field)},');
    }
    result.writeln(']);');

    if (generateMixin) result.write(_generateMixin(enumName, fields));

    return result.toString();
  }

  String _generateMixin(String enumName, Iterable<FieldElement> fields) {
    final result = new StringBuffer();

    result.writeln('class _\$${enumName}Meta {');
    result.writeln('const _\$${enumName}Meta();');
    for (final field in fields) {
      final fieldName = field.displayName;
      result.writeln('$enumName get $fieldName => _\$${_getGeneratedIdentifier(
          field)};');
    }
    result.writeln('}');
    result.writeln('abstract class _\$${enumName}Mixin {');
    result.writeln(
        '_\$${enumName}Meta get $enumName => const _\$${enumName}Meta();');
    result.writeln('}');

    return result.toString();
  }

  String _getGeneratedIdentifier(FieldElement field) {
    final fieldName = field.displayName;
    return field.computeNode().toString().substring('$fieldName = _\$'.length);
  }

  String _getValueOfIdentifier(String source, String enumName) {
    final matches = new RegExp(r'static ' +
            enumName +
            r' valueOf\(String name\) \=\> \_\$(\w+)\(name\)\;')
        .allMatches(source);
    return matches.isEmpty ? null : matches.first.group(1);
  }

  String _getValuesIdentifier(String source, String enumName) {
    final matches = new RegExp(
            r'static BuiltSet<' + enumName + r'> get values => _\$(\w+)\;')
        .allMatches(source);
    return matches.isEmpty ? null : matches.first.group(1);
  }
}
