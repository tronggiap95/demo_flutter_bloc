import 'package:json_annotation/json_annotation.dart';
import 'package:octo360/data/model/graphql/model/follow_on_study/follow_on_study.dart';

part 'ecg0_study_info.g.dart';

@JsonSerializable(explicitToJson: true)
class ECG0StudyInfo {
  final FollowOnStudy? followOnStudy;

  ECG0StudyInfo({
    this.followOnStudy,
  });

  factory ECG0StudyInfo.fromJson(Map<String, dynamic> json) =>
      _$ECG0StudyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ECG0StudyInfoToJson(this);
}
