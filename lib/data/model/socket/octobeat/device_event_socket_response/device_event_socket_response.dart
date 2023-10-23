import 'package:json_annotation/json_annotation.dart';

part 'device_event_socket_response.g.dart';

@JsonSerializable(explicitToJson: true)
class DeviceEventSocketResponse {
  final String id;
  final String status;

  DeviceEventSocketResponse({required this.id, required this.status});

  factory DeviceEventSocketResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceEventSocketResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceEventSocketResponseToJson(this);
}
