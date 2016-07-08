// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:async';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
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

abstract class TestEnumMixin = Object with _$TestEnumMixin;
''';

final String correctOutput = r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: library test_enum
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

class _$TestEnumMeta {
  const _$TestEnumMeta();
  TestEnum get yes => _$yes;
  TestEnum get no => _$no;
  TestEnum get maybe => _$maybe;
  TestEnum valueOf(String name) => _$valueOf(name);
  BuiltSet<TestEnum> get values => _$values;
}

abstract class _$TestEnumMixin {
  _$TestEnumMeta get TestEnum => const _$TestEnumMeta();
}
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
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Specify a type for field "anInt".
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
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Import EnumClass: import 'package:enum_class/enum_class.dart';
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
'''), contains(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Import generated part: part 'test_enum.g.dart';
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
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Make field "yes" const.
//        2. Make field "no" const.
//        3. Make field "maybe" const.
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
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Make field "yes" static const.
//        2. Make field "no" static const.
//        3. Make field "maybe" static const.
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

abstract class TestEnumMixin = Object with _$TestEnumMixin;
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
// Target: library test_enum
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
// Target: library test_enum
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
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Generated identifier "_$no" is used multiple times in test_enum, change to something else.
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
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Generated identifier "_$no" is used multiple times in test_enum, change to something else.
'''));
    });

    test('does not fail with clash across multiple files', () async {
      expect(
          await generateTwo(correctInput,
              correctInput.replaceAll('test_enum', 'test_enum_two')),
          endsWith(correctOutput.replaceAll('test_enum', 'test_enum_two')));
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
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Have exactly one constructor: const TestEnum._(String name) : super(name);
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
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Have exactly one constructor: const TestEnum._(String name) : super(name);
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
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Have exactly one constructor: const TestEnum._(String name) : super(name);
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
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Add getter: static BuiltSet<TestEnum> get values => _$values
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
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Add method: static TestEnum valueOf(String name) => _$valueOf(name)
'''));
    });

    test('fails with error on wrong mixin declaration', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}

class TestEnumMixin = Object with _$TestEnumMixin;
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: library test_enum
// **************************************************************************

// Error: Please make the following changes to use EnumClass:
//
//        1. Remove mixin or declare using exactly: abstract class TestEnumMixin = Object with _$TestEnumMixin;
'''));
    });

    test('is robust to newlines in input', () async {
      expect(await generate(r'''
library test_enum;

import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name)
      : super(name);

  static BuiltSet<TestEnum> get values =>
      _$values;
  static TestEnum valueOf(String name) =>
      _$valueOf(name);
}

abstract class TestEnumMixin = Object with _$TestEnumMixin;
'''), endsWith(correctOutput));
    });
  });
}

// Test setup.

final String pkgName = 'pkg';
final PackageGraph packageGraph =
    new PackageGraph.fromRoot(new PackageNode(pkgName, null, null, null));

// Recreate EnumClassGenerator for each test because we repeatedly create
// enums with the same name in the same library, which will clash.
PhaseGroup get phaseGroup => new PhaseGroup.singleAction(
    new GeneratorBuilder([new EnumClassGenerator()]),
    new InputSet(pkgName, const ['lib/*.dart']));

Future<String> generate(String source) async {
  final srcs = <String, String>{
    'enum_class|lib/enum_class.dart': enumClassSource,
    '$pkgName|lib/test_enum.dart': source,
  };

  final writer = new InMemoryAssetWriter();
  await testPhases(phaseGroup, srcs,
      packageGraph: packageGraph, writer: writer);
  return writer.assets[new AssetId(pkgName, 'lib/test_enum.g.dart')]?.value;
}

Future<String> generateTwo(String source, String source2) async {
  final srcs = {
    'enum_class|lib/enum_class.dart': enumClassSource,
    '$pkgName|lib/test_enum.dart': source,
    '$pkgName|lib/test_enum_two.dart': source2
  };

  final writer = new InMemoryAssetWriter();
  await testPhases(phaseGroup, srcs,
      packageGraph: packageGraph, writer: writer);
  return writer.assets[new AssetId(pkgName, 'lib/test_enum.g.dart')]?.value +
      writer.assets[new AssetId(pkgName, 'lib/test_enum_two.g.dart')]?.value;
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
