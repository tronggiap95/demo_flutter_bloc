import 'package:octo360/domain/bloc/global_bloc.dart';
import 'package:octo360/l10n/locale_enum.dart';

class ImagesApp {
//***************************## JSON ##************************ */
  static String loadingDialogAnimation =
      ImagesPath.getPath('loading_dialog.json');
  static String circleBluetooth = ImagesPath.getPath('circle_bluetooth.json');
  static String loadingAnimation = ImagesPath.getPath('loading_animation.json');
  static String studyUploading = ImagesPath.getPath('study_uploading.json');
//***************************## GIF ##************************ */

//***************************## JPG ##************************ */

//***************************## PNG ##************************ */
  static String octobeatDevice = ImagesPath.getPath('octobeat_device.png');
  static String bgHome = ImagesPath.getPath('bg_home.png');
  static String octoBeatConnectSuccessful =
      ImagesPath.getPath('octobeat_connect_successful.png');
  static String octoBeatDisconnected =
      ImagesPath.getPath('octobeat_disconnected.png');
  static String octoBeatBlueLight =
      ImagesPath.getPath('octobeat_blue_light.png');
  static String octoBeatGreenLight =
      ImagesPath.getPath('octobeat_green_light.png');
  static String octoBeatWhiteLight =
      ImagesPath.getPath('octobeat_white_light.png');
  static String octoBeatLeadDisconnected =
      ImagesPath.getPath('octobeat_lead_disconnected.png');
  static String octoBeatDisconnectedCard =
      ImagesPath.getPath('octobeat_disconnected_card.png');
  static String wirelessSignal = ImagesPath.getPath('wireless_signal.png');

//***************************## SVG ##************************ */
  static String icError = ImagesPath.getPath('ic_error.svg');
  static String icSuccessSync = ImagesPath.getPath('ic_success_sync.svg');
  static String icWarningTriangle =
      ImagesPath.getPath('ic_warning_triangle.svg');
  static String success = ImagesPath.getPath('success.svg');
  static String failed = ImagesPath.getPath('failed.svg');
  static String attention = ImagesPath.getPath('attention.svg');
  static String icCaretLeft = ImagesPath.getPath('ic_caret_left.svg');
  static String icArrowBackAndroid =
      ImagesPath.getPath('ic_arrow_back_android.svg');
  static String icBluetooth = ImagesPath.getPath('ic_bluetooth.svg');
  static String bluetoothStopped = ImagesPath.getPath('bluetooth_stopped.svg');
  static String icCaret = ImagesPath.getPath('ic_caret.svg');
  static String icWarning = ImagesPath.getPath('ic_warning.svg');
  static String icUserManualDevices =
      ImagesPath.getPath('ic_user_manual_devices.svg');
  static String icQuickGuideDevices =
      ImagesPath.getPath('ic_quick_guide_devices.svg');
  static String icTroubleshootingDevices =
      ImagesPath.getPath('ic_troubleshooting_devices.svg');
  static String icContactSupportDevices =
      ImagesPath.getPath('ic_contact_support_devices.svg');
  static String icContactSupport = ImagesPath.getPath('ic_contact_support.svg');
  static String icOctobeat = ImagesPath.getPath('ic_octobeat.svg');
  static String icDeviceAway = ImagesPath.getPath('ic_device_away.svg');
  static String icDeviceOnline = ImagesPath.getPath('ic_device_online.svg');
  static String icDeviceOffline = ImagesPath.getPath('ic_device_offline.svg');
  static String icBatteryCharging =
      ImagesPath.getPath('ic_battery_charging.svg');
  static String icSnackbarWarning =
      ImagesPath.getPath('ic_snackbar_warning.svg');
  static String icFailed = ImagesPath.getPath('ic_failed.svg');
  static String icInformationBlue =
      ImagesPath.getPath('ic_information_blue.svg');
  static String studyAborted = ImagesPath.getPath('study_aborted.svg');
  static String icWarningRed = ImagesPath.getPath('ic_warning_red.svg');
  static String icAttentionNeeded =
      ImagesPath.getPath('ic_attention_needed.svg');
  static String octobeatGuideFirst =
      ImagesPath.getPath('octobeat_guide_first.svg');
  static String octobeatGuideSecond =
      ImagesPath.getPath('octobeat_guide_second.svg');
  static String octobeatGuideThird =
      ImagesPath.getPath('octobeat_guide_third.svg');
  static String llIcon = ImagesPath.getPath('ll_icon.svg');
  static String laIcon = ImagesPath.getPath('la_icon.svg');
  static String raIcon = ImagesPath.getPath('ra_icon.svg');
  static String icClose = ImagesPath.getPath('ic_close.svg');
  static String pageNotFound = ImagesPath.getPath('page_not_found.svg');
  static String icLightbulb = ImagesPath.getPath('ic_lightbulb.svg');
  static String icSquareCheckbox = ImagesPath.getPath('ic_square_checkbox.svg');
  static String icSquareCheckboxFill =
      ImagesPath.getPath('ic_square_checkbox_fill.svg');
  static String welcomeBackground =
      ImagesPath.getPath('welcome_background.png');
  static String logoSplashScreen = ImagesPath.getPath('logo_splash_screen.svg');
  static String icArrowLeft = ImagesPath.getPath('ic_arrow_left.svg');
  static String icBatteryFull = ImagesPath.getPath('ic_battery_full.svg');
  static String icBatteryLow = ImagesPath.getPath('ic_battery_low.svg');
  static String octobeatTextLogo = ImagesPath.getPath('octobeat_text_logo.svg');
  static String circleDay = ImagesPath.getPath('circle_day.svg');
  static String circleHour = ImagesPath.getPath('circle_hour.svg');
  static String circleMin = ImagesPath.getPath('circle_min.svg');
  static String studyCompleted = ImagesPath.getPath('study_completed.svg');
  static String studyUploaded = ImagesPath.getPath('study_uploaded.svg');

//***************************## END ##************************ */
}

extension ImagesPath on ImagesApp {
  static String getPath(String name) {
    if (name.contains('.svg')) {
      return 'assets/svg/$name';
    }
    if (name.contains('.png')) {
      return 'assets/png/$name';
    }
    if (name.contains('.jpg')) {
      return 'assets/jpg/$name';
    }
    if (name.contains('.json')) {
      return 'assets/json/$name';
    }
    if (name.contains('.gif')) {
      return 'assets/gif/$name';
    }
    return 'assets/svg/$name';
  }
}

extension StringImagePathExt on String {
  String withLocale({LocaleEnum? localeEnum}) {
    LocaleEnum currentLocale;
    if (localeEnum != null) {
      currentLocale = localeEnum;
    } else {
      currentLocale = GlobalBloc.currentLocaleStatic;
    }

    if (currentLocale == LocaleEnum.en) {
      return this;
    }

    if (contains('assets/${currentLocale.getLocale.languageCode}/')) {
      return this;
    }
    return replaceFirst(
        RegExp(r'/'), '/${currentLocale.getLocale.languageCode}/');
  }
}
