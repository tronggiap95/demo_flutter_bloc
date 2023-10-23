// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecg0_artifact_statistic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ECG0ArtifactStatistic _$ECG0ArtifactStatisticFromJson(
        Map<String, dynamic> json) =>
    ECG0ArtifactStatistic(
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      shouldBeResolved: json['shouldBeResolved'] as bool?,
      lastIssueFound: json['lastIssueFound'] as String?,
      commonIssueFound: json['commonIssueFound'] as String?,
    );

Map<String, dynamic> _$ECG0ArtifactStatisticToJson(
    ECG0ArtifactStatistic instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('date', instance.date?.toIso8601String());
  writeNotNull('shouldBeResolved', instance.shouldBeResolved);
  writeNotNull('lastIssueFound', instance.lastIssueFound);
  writeNotNull('commonIssueFound', instance.commonIssueFound);
  return val;
}
