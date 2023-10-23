import 'package:json_annotation/json_annotation.dart';

enum PlatformTypeEnum {
  @JsonValue("IOS")
  ios,
  @JsonValue("ANDROID")
  android;

  get value {
    switch (this) {
      case PlatformTypeEnum.ios:
        return "IOS";
      case PlatformTypeEnum.android:
        return "ANDROID";
    }
  }
}
