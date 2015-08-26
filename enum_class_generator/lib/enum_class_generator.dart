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
  Future<String> generate(Element element) async {
    if (element is! ClassElement) {
      return null;
    }
    final classElement = element as ClassElement;
    final enumName = classElement.displayName;

    // TODO(davidmorgan): do this in a way that works if the import is missing.
    if (classElement.allSupertypes
        .where((i) => i.displayName == 'EnumClass')
        .isEmpty) return null;

    final fields = getApplicableFields(classElement);
    final errors = concat([
      checkPart(classElement),
      checkFields(fields),
      checkConstructor(classElement),
      checkValuesGetter(classElement),
      checkValueOf(classElement)
    ]);

    if (errors.isNotEmpty) {
      throw new InvalidGenerationSourceError(
          'Please make changes to use EnumClass.',
          todo: errors.join(' '));
    }

    return generateCode(enumName, fields.map((field) => field.displayName));
  }

  Iterable<String> checkPart(ClassElement classElement) {
    final fileName =
        classElement.library.source.shortName.replaceAll('.dart', '');
    final expectedCode = "part '$fileName.g.dart';";
    return classElement.library.source.contents.data.contains(expectedCode)
        ? <String>[]
        : <String>['Import generated part: $expectedCode'];
  }

  Iterable<FieldElement> getApplicableFields(ClassElement classElement) {
    final enumName = classElement.displayName;
    final result = <FieldElement>[];
    for (final field in classElement.fields) {
      final type = field.getter.returnType.displayName;
      if (!field.isSynthetic && type == enumName) result.add(field);
    }
    return result;
  }

  Iterable<String> checkFields(Iterable<FieldElement> fields) {
    final result = <String>[];
    for (final field in fields) {
      final fieldName = field.displayName;
      if (!field.isConst && !field.isStatic) {
        result.add('Make field "$fieldName" static const.');
        continue;
      } else if (!field.isConst) {
        result.add('Make field "$fieldName" const.');
        continue;
      }

      if (field.computeNode().toString() != '$fieldName = _\$$fieldName') {
        result.add(
            'Initialize field "$fieldName" with generated value "_\$$fieldName".');
      }
    }
    return result;
  }

  Iterable<String> checkConstructor(ClassElement classElement) {
    final enumName = classElement.displayName;
    final expectedCode = 'const $enumName._(String name) : super(name);';
    return classElement.constructors.length == 1 &&
        classElement.constructors.single.computeNode().toString() ==
            expectedCode ? <String>[] : <String>['Constructor: $expectedCode'];
  }

  Iterable<String> checkValuesGetter(ClassElement classElement) {
    // TODO(davidmorgan): do this without reading the whole source.
    final enumName = classElement.displayName;
    final expectedCode = 'static BuiltSet<$enumName> get values => _\$values;';
    return classElement.source.contents.data.contains(expectedCode)
        ? <String>[]
        : <String>['Getter: $expectedCode'];
  }

  Iterable<String> checkValueOf(ClassElement classElement) {
    // TODO(davidmorgan): do this without reading the whole source.
    final enumName = classElement.displayName;
    final expectedCode =
        'static $enumName valueOf(String name) => _\$valueOf(name);';
    return classElement.source.contents.data.contains(expectedCode)
        ? <String>[]
        : <String>['Method: $expectedCode'];
  }

  String generateCode(String enumName, Iterable<String> fieldNames) {
    final result = new StringBuffer();

    for (final fieldName in fieldNames) {
      result.writeln('const $enumName _\$$fieldName = '
          'const $enumName._(\'$fieldName\');');
    }

    result.writeln('');
    result.writeln('$enumName _\$valueOf(String name) {'
        'switch (name) {');
    for (final fieldName in fieldNames) {
      result.writeln('case \'$fieldName\': return _\$$fieldName;');
    }
    result.writeln('default: throw new ArgumentError(name);');
    result.writeln('}}');

    result.writeln('');
    result.writeln('final BuiltSet<$enumName> _\$values ='
        'new BuiltSet<$enumName>(const [');
    for (final fieldName in fieldNames) {
      result.writeln('_\$$fieldName,');
    }
    result.writeln(']);');

    return result.toString();
  }
}
