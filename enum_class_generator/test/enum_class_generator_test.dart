// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:enum_class_generator/enum_class_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

final String correctInput = r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
''';

final String correctOutput = r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

const TestEnum _$yes = const TestEnum._('yes');
const TestEnum _$no = const TestEnum._('no');
const TestEnum _$maybe = const TestEnum._('maybe');

TestEnum _$valueOf(String name) {
  switch (name) {
    case 'yes':
      return _$yes;
    case 'no':
      return _$no;
    case 'maybe':
      return _$maybe;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<TestEnum> _$values =
    new BuiltSet<TestEnum>(const [_$yes, _$no, _$maybe,]);
''';

void main() {
  group('generator', () {
    test('produces correct output for correct input', () async {
      expect(await generate(correctInput), endsWith(correctOutput));
    });

    test('produces two correct output for two correct inputs', () async {
      expect(
          await generateTwo(correctInput,
              correctInput.replaceAll('test_enum', 'test_enum_two')),
          endsWith(correctOutput.replaceAll('test_enum', 'test_enum_two')));
    });

    test('allows part statement with double quotes', () async {
      expect(
          await generate(correctInput.replaceAll(
              "part 'test_enum.g.dart'", 'part "test_enum.g.dart"')),
          endsWith(correctOutput));
    });

    test('ignores fields of different type', () async {
      expect(
          await generate(correctInput.replaceAll(
              'class TestEnum extends EnumClass {',
              'class TestEnum extends EnumClass {\n'
              '  static const int anInt = 3;')),
          endsWith(correctOutput));
    });

    test('fails on dynamic fields', () async {
      expect(
          await generate(correctInput.replaceAll(
              'class TestEnum extends EnumClass {',
              'class TestEnum extends EnumClass {\n'
              '  static const anInt = 3;')),
          endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Specify a type for field "anInt".
'''));
    });

    test('fails with error on missing enum_class import', () async {
      expect(await generate(r'''
library test_enum;

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Import EnumClass: import 'package:enum_class/enum_class.dart';
'''));
    });

    test('fails with error on missing part statement', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'src_par.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Import generated part: part 'test_enum.g.dart';
'''));
    });

    test('fails with error on non-const static fields', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static TestEnum yes = _$yes;
  static TestEnum no = _$no;
  static TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Make field "yes" const. Make field "no" const. Make field "maybe" const.
'''));
    });

    test('fails with error on non-const non-static fields', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  TestEnum yes = _$yes;
  TestEnum no = _$no;
  TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Make field "yes" static const. Make field "no" static const. Make field "maybe" static const.
'''));
    });

    test('ignores static const fields of wrong type', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const int count = 0;
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(correctOutput));
    });

    test('matches generated names to rhs for field names', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$no;
  static const TestEnum no = _$maybe;
  static const TestEnum maybe = _$yes;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

const TestEnum _$no = const TestEnum._('yes');
const TestEnum _$maybe = const TestEnum._('no');
const TestEnum _$yes = const TestEnum._('maybe');

TestEnum _$valueOf(String name) {
  switch (name) {
    case 'yes':
      return _$no;
    case 'no':
      return _$maybe;
    case 'maybe':
      return _$yes;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<TestEnum> _$values =
    new BuiltSet<TestEnum>(const [_$no, _$maybe, _$yes,]);
'''));
    });

    test('matches generated names to values and valueOf', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$vls;
  static TestEnum valueOf(String name) => _$vlOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

const TestEnum _$yes = const TestEnum._('yes');
const TestEnum _$no = const TestEnum._('no');
const TestEnum _$maybe = const TestEnum._('maybe');

TestEnum _$vlOf(String name) {
  switch (name) {
    case 'yes':
      return _$yes;
    case 'no':
      return _$no;
    case 'maybe':
      return _$maybe;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<TestEnum> _$vls =
    new BuiltSet<TestEnum>(const [_$yes, _$no, _$maybe,]);
'''));
    });

    test('fails with error on name clash for field rhs', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$no;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$yes;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Generated identifier "_$no" is used multiple times, change to something else.
'''));
    });

    test('fails with error on name clash for values', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$no;
  static const TestEnum no = _$maybe;
  static const TestEnum maybe = _$yes;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$no;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Generated identifier "_$no" is used multiple times, change to something else.
'''));
    });

    test('fails with error on missing constructor', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Constructor: const TestEnum._(String name) : super(name);
'''));
    });

    test('fails with error on incorrect constructor', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Constructor: const TestEnum._(String name) : super(name);
'''));
    });

    test('fails with error on too many constructors', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);
  TestEnum._create(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}

abstract class BuiltSet<T> {
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Constructor: const TestEnum._(String name) : super(name);
'''));
    });

    test('fails with error on missing values getter', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Getter: static BuiltSet<TestEnum> get values => _$values
'''));
    });

    test('fails with error on missing valueOf', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Method: static TestEnum valueOf(String name) => _$valueOf(name)
'''));
    });
  });
}

// Test setup.

Future<String> generate(String source) async {
  final tempDir =
      Directory.systemTemp.createTempSync('enum_class_generator.dart.');
  final packageDir = new Directory(tempDir.path + '/packages')..createSync();
  final enumClassDir = new Directory(packageDir.path + '/enum_class')
    ..createSync();
  final enumClassFile = new File(enumClassDir.path + '/enum_class.dart')
    ..createSync();
  enumClassFile.writeAsStringSync(enumClassSource);

  final libDir = new Directory(tempDir.path + '/lib')..createSync();
  final sourceFile = new File(libDir.path + '/test_enum.dart');
  sourceFile.writeAsStringSync(source);

  await build([], [new EnumClassGenerator()],
      projectPath: tempDir.path, librarySearchPaths: <String>['lib']);
  final outputFile = new File(libDir.path + '/test_enum.g.dart');
  return outputFile.existsSync() ? outputFile.readAsStringSync() : '';
}

Future<String> generateTwo(String source, String source2) async {
  final tempDir =
      Directory.systemTemp.createTempSync('enum_class_generator.dart.');
  final packageDir = new Directory(tempDir.path + '/packages')..createSync();
  final enumClassDir = new Directory(packageDir.path + '/enum_class')
    ..createSync();
  final enumClassFile = new File(enumClassDir.path + '/enum_class.dart')
    ..createSync();
  enumClassFile.writeAsStringSync(enumClassSource);

  final libDir = new Directory(tempDir.path + '/lib')..createSync();
  final sourceFile = new File(libDir.path + '/test_enum.dart');
  sourceFile.writeAsStringSync(source);
  final sourceFile2 = new File(libDir.path + '/test_enum_two.dart');
  sourceFile2.writeAsStringSync(source2);

  await build([], [new EnumClassGenerator()],
      projectPath: tempDir.path, librarySearchPaths: <String>['lib']);
  final outputFile = new File(libDir.path + '/test_enum.g.dart');
  final outputFile2 = new File(libDir.path + '/test_enum_two.g.dart');
  return (outputFile.existsSync() ? outputFile.readAsStringSync() : '') +
      (outputFile2.existsSync() ? outputFile2.readAsStringSync() : '');
}

const String enumClassSource = r'''
library enum_class;

class EnumClass {
  final String name;

  const EnumClass(this.name);

  @override
  String toString() => name;
}
''';

const String builtCollectionSource = r'''
library built_collection;

abstract class BuiltSet<E> {
}
''';
