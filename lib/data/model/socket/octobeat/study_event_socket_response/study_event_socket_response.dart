import 'package:json_annotation/json_annotation.dart';

part 'study_event_socket_response.g.dart';

@JsonSerializable(explicitToJson: true)
class StudyEventSocketResponse {
  final String id;
  final String status;

  StudyEventSocketResponse({required this.id, required this.status});

  factory StudyEventSocketResponse.fromJson(Map<String, dynamic> json) =>
      _$StudyEventSocketResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StudyEventSocketResponseToJson(this);
}
