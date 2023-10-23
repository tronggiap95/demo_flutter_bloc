import 'package:json_annotation/json_annotation.dart';

enum OctoDeviceStatus {
  @JsonValue('Online')
  online,
  @JsonValue('Offline')
  offline;

  static OctoDeviceStatus from(String? value) {
    if (value == null) {
      return OctoDeviceStatus.offline;
    }
    switch (value) {
      case 'Offline':
        return OctoDeviceStatus.offline;
      default:
        return OctoDeviceStatus.online;
    }
  }
}
