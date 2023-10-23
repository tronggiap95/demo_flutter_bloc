import 'package:json_annotation/json_annotation.dart';

part 'ecg0_facility.g.dart';

@JsonSerializable()
class ECG0Facility {
  final String? name;

  ECG0Facility({
    this.name,
  });

  factory ECG0Facility.fromJson(Map<String, dynamic> json) =>
      _$ECG0FacilityFromJson(json);

  Map<String, dynamic> toJson() => _$ECG0FacilityToJson(this);
}
