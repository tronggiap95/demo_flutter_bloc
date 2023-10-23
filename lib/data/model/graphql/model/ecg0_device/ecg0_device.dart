import 'package:json_annotation/json_annotation.dart';
import 'package:octo360/data/model/graphql/model/ecg0_device_last_sync/ecg0_device_last_sync.dart';
part 'ecg0_device.g.dart';

@JsonSerializable(explicitToJson: true)
class ECG0Device {
  final String? id;
  final String? deviceId;
  final String? status;
  final ECG0DeviceLastSync? lastSync;

  ECG0Device({
    this.id,
    this.deviceId,
    this.status,
    this.lastSync,
  });

  factory ECG0Device.fromJson(Map<String, dynamic> json) =>
      _$ECG0DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$ECG0DeviceToJson(this);
}
