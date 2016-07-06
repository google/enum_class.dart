// Copyright (c) 2016, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library enum_class_generator.source_library;

import 'package:analyzer/dart/element/element.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:enum_class_generator/src/library_elements.dart';
import 'package:enum_class_generator/src/source_class.dart';
import 'package:quiver/iterables.dart';
import 'package:source_gen/source_gen.dart';

part 'source_library.g.dart';

abstract class SourceLibrary
    implements Built<SourceLibrary, SourceLibraryBuilder> {
  String get name;
  String get fileName;
  String get source;
  BuiltList<SourceClass> get classes;

  SourceLibrary._();
  factory SourceLibrary([updates(SourceLibraryBuilder b)]) = _$SourceLibrary;

  factory SourceLibrary.fromLibraryElement(LibraryElement libraryElement) {
    final result = new SourceLibraryBuilder()
      ..name = libraryElement.name
      ..fileName = libraryElement.source.shortName.replaceAll('.dart', '')
      ..source = libraryElement.source.contents.data;

    for (final classElement
        in LibraryElements.getClassElements(libraryElement)) {
      if (SourceClass.isMissingImportFor(classElement)) {
        throw _makeError(
            ["Import EnumClass: import 'package:enum_class/enum_class.dart';"]);
      } else if (SourceClass.needsEnumClass(classElement)) {
        result.classes.add(new SourceClass.fromClassElement(classElement));
      }
    }
    return result.build();
  }

  String generateCode() {
    if (classes.isEmpty) return null;

    final errors = _computeErrors();
    if (errors.isNotEmpty) throw _makeError(errors);

    return classes.map((c) => c.generateCode()).join('\n');
  }

  Iterable<String> _computeErrors() {
    return concat([
      _checkPart(),
      _checkIdentifiers(),
      concat(classes.map((c) => c.computeErrors()))
    ]);
  }

  Iterable<String> _checkPart() {
    final expectedCode = "part '$fileName.g.dart';";
    final alternativeExpectedCode = 'part "$fileName.g.dart";';
    return source.contains(expectedCode) ||
            source.contains(alternativeExpectedCode)
        ? <String>[]
        : <String>['Import generated part: $expectedCode'];
  }

  Iterable<String> _checkIdentifiers() {
    final result = <String>[];
    final seenIdentifiers = new Set<String>();
    final reportedIdentifiers = new Set<String>();

    for (final sourceClass in classes) {
      for (final identifier in sourceClass.identifiers) {
        if (seenIdentifiers.contains(identifier) &&
            !reportedIdentifiers.contains(identifier)) {
          reportedIdentifiers.add(identifier);
          result.add(
              'Generated identifier "$identifier" is used multiple times in'
              ' $name, change to something else.');
        }
        seenIdentifiers.add(identifier);
      }
    }

    return result;
  }
}

abstract class SourceLibraryBuilder
    implements Builder<SourceLibrary, SourceLibraryBuilder> {
  String name;
  String fileName;
  String source;
  ListBuilder<SourceClass> classes = new ListBuilder<SourceClass>();

  SourceLibraryBuilder._();
  factory SourceLibraryBuilder() = _$SourceLibraryBuilder;
}

InvalidGenerationSourceError _makeError(Iterable<String> todos) {
  final message =
      new StringBuffer('Please make the following changes to use EnumClass:\n');
  for (var i = 0; i != todos.length; ++i) {
    message.write('\n${i + 1}. ${todos.elementAt(i)}');
  }

  return new InvalidGenerationSourceError(message.toString());
}
