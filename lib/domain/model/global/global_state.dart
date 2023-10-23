import 'package:octo360/l10n/locale_enum.dart';

enum ReloadState {
  none,
  reloadOctoBeatDevice,
}

class GlobalState {
  LocaleEnum currentLocale;

  GlobalState({
    this.currentLocale = LocaleEnum.vi,
  });
}
