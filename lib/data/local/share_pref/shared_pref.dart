import 'dart:convert';

import 'package:octo360/application/enum/app_lifecycle_state_enum.dart';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/data/local/notification/local_notification_modal/local_notification_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static const _currentLocale = '_currentLocale';
  static const _hasShowOctoBeatFirstGuide = '_hasShowOctoBeatFirstGuide';
  static const _appLifecycleState = '_appLifecycleState';
  static const _fromNotification = '_fromNotification';
  static const _hasShowCompletedStudyDialog = '_hasShowCompletedStudyDialog';

  static void setCurrentLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentLocale, locale);
  }

  static Future<String?> getCurrentLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentLocale);
  }

  static void setHasShowOctoBeatFirstGuide(bool hasShow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasShowOctoBeatFirstGuide, hasShow);
  }

  static Future<bool> getHasShowOctoBeatFirstGuide() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasShowOctoBeatFirstGuide) ?? false;
  }

  static Future<void> setAppLifecycleState(
      AppLifecycleStateEnum? appLifecycleStateEnum) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (appLifecycleStateEnum == null) {
        prefs.remove(_appLifecycleState);
        return;
      }
      final json = jsonEncode(appLifecycleStateEnum.getValue);
      await prefs.setString(_appLifecycleState, json);
    } catch (error) {
      Log.e("setAppLifecycleState $error");
    }
  }

  static Future<AppLifecycleStateEnum?> getAppLifecycleState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_appLifecycleState);
      if (json == null) {
        return null;
      }
      return AppLifecycleStateEnum.getEnum(jsonDecode(json));
    } catch (error) {
      Log.e("getAppLifecycleState $error");
      return null;
    }
  }

  static Future<void> setFromNotification(
      FromNotification? fromNotification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (fromNotification == null) {
        prefs.remove(_fromNotification);
        return;
      }
      final json = jsonEncode(fromNotification.toJson());
      await prefs.setString(_fromNotification, json);
    } catch (error) {
      Log.e("setUser $error");
    }
  }

  static Future<void> removeFromNotification() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fromNotification);
  }

  static Future<FromNotification?> getFromNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_fromNotification);
      if (json == null) {
        return null;
      }
      return FromNotification.fromJson(jsonDecode(json));
    } catch (error) {
      Log.e("get ListLocalLocalMedication $error");
      return null;
    }
  }

  static void setHasShowCompletedStudyDialog(bool hasShow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasShowCompletedStudyDialog, hasShow);
  }

  static Future<bool> getHasShowCompletedStudyDialog() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasShowCompletedStudyDialog) ?? false;
  }
}
