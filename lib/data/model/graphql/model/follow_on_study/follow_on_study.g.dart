// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_on_study.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowOnStudy _$FollowOnStudyFromJson(Map<String, dynamic> json) =>
    FollowOnStudy(
      studyType: json['studyType'] as String?,
    );

Map<String, dynamic> _$FollowOnStudyToJson(FollowOnStudy instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('studyType', instance.studyType);
  return val;
}
