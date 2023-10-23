// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:octo360/application/constants/octobeat_symptoms_snapshot_static_data.dart';

class OctoBeatSnapshotSymptomsTriggerState {
  List<String> selectedSymptoms;
  int countDown;
  int eventTime;
  bool hasData;
  OctoBeatSnapshotSymptomsTriggerState({
    this.selectedSymptoms = const [],
    this.eventTime = 0,
    this.hasData = false,
    this.countDown = OctoBeatSymptomsSnapshotStaticData.defaultCountdownTime,
  });

  OctoBeatSnapshotSymptomsTriggerState copyWith({
    List<String>? selectedSymptoms,
    int? countDown,
    int? eventTime,
    bool? hasData,
  }) {
    return OctoBeatSnapshotSymptomsTriggerState(
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
      countDown: countDown ?? this.countDown,
      eventTime: eventTime ?? this.eventTime,
      hasData: hasData ?? this.hasData,
    );
  }
}
