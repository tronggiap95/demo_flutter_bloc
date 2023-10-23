import 'package:flutter/material.dart';

enum LocaleEnum {
  en('en'),
  vi('vi');

  final String value;

  const LocaleEnum(this.value);

  Locale get getLocale {
    switch (this) {
      case en:
        return Locale(LocaleEnum.en.value);
      case vi:
        return Locale(LocaleEnum.vi.value);
      default:
        return Locale(LocaleEnum.vi.value);
    }
  }
}

extension LocaleEnumExt on LocaleEnum {
  String withTag(String tag) {
    return getLocale.languageCode + tag;
  }
}
