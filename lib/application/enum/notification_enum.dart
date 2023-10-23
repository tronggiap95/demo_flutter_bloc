import 'package:json_annotation/json_annotation.dart';

enum LocalNotificationType {
  @JsonValue('none')
  none,
  @JsonValue('octoBeatSymptomsTrigger')
  octoBeatSymptomsTrigger;

  String get getValue {
    switch (this) {
      case LocalNotificationType.none:
        return 'None';
      case LocalNotificationType.octoBeatSymptomsTrigger:
        return 'octobeatSymptomsTrigger';
    }
  }

  String get getId {
    switch (this) {
      case LocalNotificationType.octoBeatSymptomsTrigger:
        return '17';
      case LocalNotificationType.none:
        return '99';
    }
  }

  static LocalNotificationType getTypeFromNumber(String typeNumber) {
    switch (typeNumber) {
      case '17':
        return LocalNotificationType.octoBeatSymptomsTrigger;
      case '99':
      default:
        return LocalNotificationType.none;
    }
  }

  String get getNotificationTitle {
    switch (this) {
      default:
        return '';
    }
  }
}
