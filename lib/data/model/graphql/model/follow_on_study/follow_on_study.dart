import 'package:json_annotation/json_annotation.dart';

part 'follow_on_study.g.dart';

@JsonSerializable()
class FollowOnStudy {
  final String? studyType;

  FollowOnStudy({
    this.studyType,
  });

  factory FollowOnStudy.fromJson(Map<String, dynamic> json) =>
      _$FollowOnStudyFromJson(json);

  Map<String, dynamic> toJson() => _$FollowOnStudyToJson(this);
}
