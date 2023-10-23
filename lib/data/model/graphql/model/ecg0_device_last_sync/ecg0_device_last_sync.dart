import 'package:json_annotation/json_annotation.dart';

part 'ecg0_device_last_sync.g.dart';

@JsonSerializable(explicitToJson: true)
class ECG0DeviceLastSync {
  final DateTime? time;
  final int? batteryLevel;
  final bool? isCharging;
  final bool? leadOn;

  ECG0DeviceLastSync({
    this.time,
    this.batteryLevel,
    this.isCharging,
    this.leadOn,
  });

  factory ECG0DeviceLastSync.fromJson(Map<String, dynamic> json) =>
      _$ECG0DeviceLastSyncFromJson(json);

  Map<String, dynamic> toJson() => _$ECG0DeviceLastSyncToJson(this);
}
