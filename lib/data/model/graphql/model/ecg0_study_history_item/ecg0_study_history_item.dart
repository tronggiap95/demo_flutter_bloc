import 'package:json_annotation/json_annotation.dart';

part 'ecg0_study_history_item.g.dart';

@JsonSerializable(explicitToJson: true)
class ECG0StudyHistoryItem {
  final DateTime? time;
  final int? batteryLevel;
  final String? status;

  ECG0StudyHistoryItem({
    this.time,
    this.batteryLevel,
    this.status,
  });

  factory ECG0StudyHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$ECG0StudyHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$ECG0StudyHistoryItemToJson(this);
}
