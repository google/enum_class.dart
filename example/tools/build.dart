// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:enum_class_generator/enum_class_generator.dart';
import 'package:source_gen/source_gen.dart';

/// Example of how to use source_gen with [EnumClassGenerator].
///
/// All you need is to import the generators you want and call [build].
void main(List<String> args) {
  build(args, [new EnumClassGenerator()]).then((result) => print(result));
}
