import 'package:json_annotation/json_annotation.dart';
import 'package:octo360/data/model/graphql/response/ecg0_study_patient_info/ecg0_study_patient_info.dart';

part 'ecg0_study_by_patient_info_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ECG0StudyByPatientInfoResponse {
  final bool? isSuccess;
  final String? message;
  final String? studyStatus;
  final ECG0StudyByPatientInfo? study;

  ECG0StudyByPatientInfoResponse({
    this.isSuccess,
    this.message,
    this.study,
    this.studyStatus,
  });

  factory ECG0StudyByPatientInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$ECG0StudyByPatientInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ECG0StudyByPatientInfoResponseToJson(this);
}
