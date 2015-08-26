// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library test_enum;

import 'package:built_collection/built_collection.dart';
import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

/// Example of how to use [EnumClass].
///
/// Enum constants must be declared as `static const`. Initialize them from
/// the generated code. For example, a constant called `yes` initializes to
/// `_$yes`.
///
/// You need to write three pieces of boilerplate to hook up the generated
/// code: a constructor called `_`, a `values` method, and a `valueOf` method.
class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
