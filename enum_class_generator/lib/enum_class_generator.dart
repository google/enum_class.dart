// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library enum_class_generator;

import 'dart:async';
import 'package:quiver/iterables.dart' show concat;

import 'package:analyzer/src/generated/element.dart';
import 'package:source_gen/source_gen.dart';

/// Generator for Enum Classes.
///
/// See https://github.com/google/enum_class.dart/tree/master/example for how
/// to use it.
class EnumClassGenerator extends Generator {
  Set<String> _usedGeneratedIdentifiers = new Set<String>();

  Future<String> generate(Element element) async {
    // Generated identifiers only have to be unique per library, reset for
    // each new library.
    if (element is LibraryElement) {
      _usedGeneratedIdentifiers = new Set<String>();
    }
    if (element is! ClassElement) {
      return null;
    }
    final classElement = element as ClassElement;
    final enumName = classElement.displayName;

    // TODO(davidmorgan): do this in a way that works if the import is missing.
    if (classElement.allSupertypes
        .where((i) => i.displayName == 'EnumClass')
        .isEmpty) return null;

    final fields = _getApplicableFields(classElement);
    final errors = concat([
      _checkPart(classElement),
      _checkFields(fields),
      _checkConstructor(classElement),
      _checkValuesGetter(classElement),
      _checkValueOf(classElement)
    ]);

    if (errors.isNotEmpty) {
      throw new InvalidGenerationSourceError(
          'Please make changes to use EnumClass.',
          todo: errors.join(' '));
    }

    return _generateCode(classElement, enumName, fields);
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
      if (!field.isSynthetic && (type == enumName || type == 'dynamic')) result
          .add(field);
    }
    return result;
  }

  Iterable<String> _checkFields(Iterable<FieldElement> fields) {
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
      if (_usedGeneratedIdentifiers.contains(identifier)) {
        result
            .add('Generated identifier "_\$$identifier" is used multiple times,'
                ' change to something else.');
      }
      _usedGeneratedIdentifiers.add(identifier);
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

  Iterable<String> _checkValuesGetter(ClassElement classElement) {
    // TODO(davidmorgan): do this without reading the whole source.
    final enumName = classElement.displayName;
    final valuesIdentifier =
        _getValuesIdentifier(classElement.source.contents.data, enumName);
    if (valuesIdentifier == null) {
      return <String>[
        'Getter: static BuiltSet<$enumName> get values => _\$values'
      ];
    } else {
      if (_usedGeneratedIdentifiers.contains(valuesIdentifier)) {
        return <String>[
          'Generated identifier "_\$$valuesIdentifier" is used multiple times,'
              ' change to something else.'
        ];
      } else {
        return <String>[];
      }
    }
  }

  Iterable<String> _checkValueOf(ClassElement classElement) {
    // TODO(davidmorgan): do this without reading the whole source.
    final enumName = classElement.displayName;

    final valueOfIdentifier =
        _getValueOfIdentifier(classElement.source.contents.data, enumName);

    if (valueOfIdentifier == null) {
      return <String>[
        'Method: static $enumName valueOf(String name) => _\$valueOf(name)'
      ];
    } else {
      if (_usedGeneratedIdentifiers.contains(valueOfIdentifier)) {
        return <String>[
          'Generated identifier "_\$$valueOfIdentifier" is used multiple times,'
              ' change to something else.'
        ];
      } else {
        return <String>[];
      }
    }
  }

  String _generateCode(ClassElement classElement, String enumName,
      Iterable<FieldElement> fields) {
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

    return result.toString();
  }

  String _getGeneratedIdentifier(FieldElement field) {
    final fieldName = field.displayName;
    return field.computeNode().toString().substring('$fieldName = _\$'.length);
  }

  String _getValueOfIdentifier(String source, String enumName) {
    final matches = new RegExp(r'static ' +
        enumName +
        r' valueOf\(String name\) \=\> \_\$(\w+)\(name\)\;').allMatches(source);
    return matches.isEmpty ? null : matches.first.group(1);
  }

  String _getValuesIdentifier(String source, String enumName) {
    final matches = new RegExp(
            r'static BuiltSet<' + enumName + r'> get values => _\$(\w+)\;')
        .allMatches(source);
    return matches.isEmpty ? null : matches.first.group(1);
  }
}
