// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecg0_study_by_patient_info_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ECG00StudyByPatientInfoFilter _$ECG00StudyByPatientInfoFilterFromJson(
        Map<String, dynamic> json) =>
    ECG00StudyByPatientInfoFilter(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      patientId: json['patientId'] as String?,
    );

Map<String, dynamic> _$ECG00StudyByPatientInfoFilterToJson(
    ECG00StudyByPatientInfoFilter instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('firstName', instance.firstName);
  writeNotNull('lastName', instance.lastName);
  writeNotNull('phone', instance.phone);
  writeNotNull('dateOfBirth', instance.dateOfBirth);
  writeNotNull('patientId', instance.patientId);
  return val;
}
