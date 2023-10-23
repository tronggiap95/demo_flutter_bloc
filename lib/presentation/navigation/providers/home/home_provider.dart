import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octo360/data/model/graphql/response/ecg0_study_patient_info/ecg0_study_patient_info.dart';
import 'package:octo360/domain/bloc/home/octobeat/octobeat_device_view_bloc.dart';
import 'package:octo360/domain/bloc/home/octobeat/octobeat_pair_device_bloc.dart';
import 'package:octo360/domain/bloc/home/octobeat/octobeat_snapshot_symptoms_trigger_bloc.dart';
import 'package:octo360/domain/bloc/home/octobeat/octobeat_study_view_bloc_extension.dart';
import 'package:octo360/presentation/screens/home/octobeat/octobeat_device_view.dart';
import 'package:octo360/presentation/screens/home/octobeat/octobeat_study_view.dart';
import 'package:octo360/presentation/screens/home/octobeat/octobeat_pair_device_screen.dart';
import 'package:octo360/presentation/screens/home/octobeat/octobeat_snapshot_symptoms_trigger.dart';

Widget octoBeatDeviceProvider() {
  return BlocProvider(
    create: (_) => OctoBeatDeviceViewBloc(),
    child: const OctoBeatDeviceView(),
  );
}

Widget octobeatPairDeviceProvider(String deviceId) {
  return BlocProvider(
    create: (_) => OctobeatPairDeviceBloc(),
    child: OctobeatPairDeviceScreen(deviceId: deviceId),
  );
}

Widget octoBeatStudyViewProvider({required ECG0StudyByPatientInfo? study}) {
  return BlocProvider(
    create: (_) => OctoBeatStudyViewBlocExtension(),
    child: OctoBeatStudyView(study: study),
  );
}

Widget octoBeatSymptomsTriggerProvider(int eventTime, int timeRemaining) {
  return BlocProvider(
    create: (_) => OctoBeatSnapshotSymptomsTriggerBloc(),
    child: OctoBeatSnapshotSymptomsTrigger(
        eventTime: eventTime, timeRemaining: timeRemaining),
  );
}
