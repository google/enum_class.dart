# Changelog

## 1.1.2

- Regenerate .g.dart files for built_value 0.1.6.

## 1.1.1

- Allow quiver 0.23.

## 1.1.0

- Upgrade analyzer, build and source_gen dependencies.

## 1.0.0

- API now stable.
- Refactor generator to split into logical classes.
- Fix "watch mode": check for duplicate identifiers per library.

## 0.2.2

- Improve error output on failure to generate.

## 0.2.1

- Add values and valueOf to generated mixin for use in Angular templates.
- Make duplicate generated name detection more robust.
- Check value and valueOf using analyzed nodes instead of raw source.
  Makes generation robust to newlines in these declarations.

## 0.2.0

- Add mixin generation for use with Angular templates.

## 0.1.0

- Upgrade to source_gen 0.5.0.
- Breaking change; see example for required changes to build.dart.

## 0.0.6

- Check for missing import statement.
- Fix constraints for source_gen.

## 0.0.5

- Fix generation across multiple files, allow reuse of generated identifiers.

## 0.0.4

- Fail on dynamic fields.
- Export BuiltSet.
- Allow part statements with double quote.

## 0.0.3

- Support multiple enums in one file by allowing arbitrary generated identifiers.

## 0.0.2

- Add accurate dependencies on SDK, analyzer.

## 0.0.1

- Generator, tests and example.
