// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecg0_study_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ECG0StudyInfo _$ECG0StudyInfoFromJson(Map<String, dynamic> json) =>
    ECG0StudyInfo(
      followOnStudy: json['followOnStudy'] == null
          ? null
          : FollowOnStudy.fromJson(
              json['followOnStudy'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ECG0StudyInfoToJson(ECG0StudyInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('followOnStudy', instance.followOnStudy?.toJson());
  return val;
}
