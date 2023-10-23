// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecg0_study_by_patient_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ECG0StudyByPatientInfoResponse _$ECG0StudyByPatientInfoResponseFromJson(
        Map<String, dynamic> json) =>
    ECG0StudyByPatientInfoResponse(
      isSuccess: json['isSuccess'] as bool?,
      message: json['message'] as String?,
      study: json['study'] == null
          ? null
          : ECG0StudyByPatientInfo.fromJson(
              json['study'] as Map<String, dynamic>),
      studyStatus: json['studyStatus'] as String?,
    );

Map<String, dynamic> _$ECG0StudyByPatientInfoResponseToJson(
    ECG0StudyByPatientInfoResponse instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('isSuccess', instance.isSuccess);
  writeNotNull('message', instance.message);
  writeNotNull('studyStatus', instance.studyStatus);
  writeNotNull('study', instance.study?.toJson());
  return val;
}
