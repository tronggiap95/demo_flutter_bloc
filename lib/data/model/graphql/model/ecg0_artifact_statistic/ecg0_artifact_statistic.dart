import 'package:json_annotation/json_annotation.dart';

part 'ecg0_artifact_statistic.g.dart';

@JsonSerializable(explicitToJson: true)
class ECG0ArtifactStatistic {
  final DateTime? date;
  final bool? shouldBeResolved;
  final String? lastIssueFound;
  final String? commonIssueFound;

  ECG0ArtifactStatistic({
    this.date,
    this.shouldBeResolved,
    this.lastIssueFound,
    this.commonIssueFound,
  });

  factory ECG0ArtifactStatistic.fromJson(Map<String, dynamic> json) =>
      _$ECG0ArtifactStatisticFromJson(json);

  Map<String, dynamic> toJson() => _$ECG0ArtifactStatisticToJson(this);
}
