# Enum Classes for Dart
[![Build Status](https://travis-ci.org/google/enum_class.dart.svg?branch=master)](https://travis-ci.org/google/enum_class.dart)
## Introduction

Enum Classes provide classes with enum features and are part of
[Libraries for Object Oriented Dart](https://github.com/google/built_value.dart/blob/master/libraries_for_object_oriented_dart.md#libraries-for-object-oriented-dart).

## Motivation

Enums are very helpful in modelling the real world: whenever there are a
small fixed set of options, an enum is a natural choice. For an object
oriented design, though, enums need to be classes. Dart falls short here,
so Enum Classes provide what's missing!

## Design

* Constants have `name` and `toString`, can be used in `switch` statements,
  and are real classes that can hold code and implement interfaces
* Generated `values` method that returns all the enum values in a `BuiltSet` (immutable set)
* Generated `valueOf` method that takes a `String`

## Using Enum Classes

Enum Classes use the [source_gen](https://github.com/dart-lang/source_gen)
library for code generation. The typical way to use it is via a `build.dart`
tool that you create for your project. When you run it, all the generated files
are updated.

Here's what you need to do to use Enum Classes:

1. Add a library dependency on enum_class to your pubspec.yaml
2. Add a dev dependency on enum_class_generator to your pubspec.yaml
3. Create a `build.dart` for your project. See example, below.
4. Run `pub run tools/build.dart` whenever you need to update the generated files.
4. To make an Enum Class, import `package:enum_class/enum_class.dart` then
   extend EnumClass.

See
[this example](https://github.com/google/enum_class.dart/tree/master/example)
for a full project with a `build.dart` and an enum.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/google/enum_class.dart/issues
