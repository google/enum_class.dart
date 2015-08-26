// GENERATED CODE - DO NOT MODIFY BY HAND
// 2015-08-18T08:36:02.364Z

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
