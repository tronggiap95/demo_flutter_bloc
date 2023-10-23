import 'dart:async';

import 'package:octo360/application/constants/octobeat_symptoms_snapshot_static_data.dart';
import 'package:octo360/domain/bloc/base/base_cubit.dart';
import 'package:octo360/domain/model/home/octobeat/octobeat_snapshot_symptoms_trigger_state.dart';
import 'package:octo_beat_plugin/octo_beat_plugin.dart';

class OctoBeatSnapshotSymptomsTriggerBloc
    extends BaseCubit<OctoBeatSnapshotSymptomsTriggerState> {
  OctoBeatSnapshotSymptomsTriggerBloc()
      : super(OctoBeatSnapshotSymptomsTriggerState());
  Timer? _timer;

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void initState(int eventTime, int timeRemaining) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => coundownTime());
    emit(
      state.copyWith(eventTime: eventTime, countDown: timeRemaining),
    );
  }

  void coundownTime() {
    var seconds = state.countDown - 1;
    if (seconds <= 0) {
      _timer?.cancel();
    }
    emit(
      state.copyWith(countDown: seconds),
    );
  }

  void onChangedSymptoms(String symptom, bool value) {
    List<String> listSymptoms = List.from(state.selectedSymptoms);
    if (value) {
      listSymptoms.add(symptom);
    } else {
      listSymptoms.remove(symptom);
    }
    emit(
      state.copyWith(
          selectedSymptoms: listSymptoms, hasData: listSymptoms.isNotEmpty),
    );
  }

  void onPressCloseButton() {
    _timer?.cancel();
  }

  void submitOctoBeatSnapshotSymptoms() {
    _timer?.cancel();
    List<String> listSymptom =
        OctoBeatSymptomsSnapshotStaticData.octoBeatSymptoms;
    List<int> listOrderSymptom = [];
    for (var order = 0; order < listSymptom.length; order++) {
      if (state.selectedSymptoms.contains(listSymptom[order])) {
        listOrderSymptom.add(order + 1);
      }
    }
    if (listOrderSymptom.isEmpty) {
      return;
    }
    OctoBeatPlugin.submitMctEvent(
      evTime: state.eventTime,
      symptoms: listOrderSymptom,
    );
  }
}
