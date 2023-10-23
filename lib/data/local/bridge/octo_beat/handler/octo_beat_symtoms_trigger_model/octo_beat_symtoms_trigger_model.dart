// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
part 'octo_beat_symtoms_trigger_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OctoBeatSymptomsSnapshot {
  OctoBeatSymptomsSnapshot({
    required this.timeTrigger,
    required this.evTime,
  });

  final DateTime timeTrigger;
  final int evTime;

  @override
  String toString() =>
      'OctoBeatSymptomsSnapshot(timeTrigger: $timeTrigger, evTime: $evTime)';

  factory OctoBeatSymptomsSnapshot.fromJson(Map<String, dynamic> json) =>
      _$OctoBeatSymptomsSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$OctoBeatSymptomsSnapshotToJson(this);
}
