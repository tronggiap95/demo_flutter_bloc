// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'ecg0_study_by_patient_info_filter.g.dart';

@JsonSerializable()
class ECG00StudyByPatientInfoFilter {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? dateOfBirth;
  final String? patientId;

  ECG00StudyByPatientInfoFilter({
    this.firstName,
    this.lastName,
    this.phone,
    this.dateOfBirth,
    this.patientId,
  });

  factory ECG00StudyByPatientInfoFilter.fromJson(Map<String, dynamic> json) =>
      _$ECG00StudyByPatientInfoFilterFromJson(json);

  Map<String, dynamic> toJson() => _$ECG00StudyByPatientInfoFilterToJson(this);

  @override
  String toString() {
    return 'ECG00StudyByPatientInfoFilter(firstName: $firstName, lastName: $lastName, phone: $phone, dateOfBirth: $dateOfBirth, patientId: $patientId)';
  }
}
