import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:octo360/l10n/locale_enum.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final supportLocales = [
  Locale(LocaleEnum.vi.value), // Vietnamese
  Locale(LocaleEnum.en.value), // English
];

const localeDelagates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
