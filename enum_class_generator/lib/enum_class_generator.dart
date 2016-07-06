// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library enum_class_generator;

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:enum_class_generator/src/source_library.dart';
import 'package:source_gen/source_gen.dart';

/// Generator for Enum Classes.
///
/// See https://github.com/google/enum_class.dart/tree/master/example for how
/// to use it.
class EnumClassGenerator extends Generator {
  @override
  Future<String> generate(Element element, BuildStep buildStep) async {
    if (element is! LibraryElement) return null;

    return new SourceLibrary.fromLibraryElement(element).generateCode();
  }
}
