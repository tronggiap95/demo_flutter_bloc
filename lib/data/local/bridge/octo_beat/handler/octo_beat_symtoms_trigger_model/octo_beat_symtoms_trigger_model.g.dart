// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'octo_beat_symtoms_trigger_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OctoBeatSymptomsSnapshot _$OctoBeatSymptomsSnapshotFromJson(
        Map<String, dynamic> json) =>
    OctoBeatSymptomsSnapshot(
      timeTrigger: DateTime.parse(json['timeTrigger'] as String),
      evTime: json['evTime'] as int,
    );

Map<String, dynamic> _$OctoBeatSymptomsSnapshotToJson(
        OctoBeatSymptomsSnapshot instance) =>
    <String, dynamic>{
      'timeTrigger': instance.timeTrigger.toIso8601String(),
      'evTime': instance.evTime,
    };
