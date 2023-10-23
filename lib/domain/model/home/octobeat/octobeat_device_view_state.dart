import 'package:octo360/data/model/graphql/response/ecg0_study_patient_info/ecg0_study_patient_info.dart';

enum ScreenState {
  loading,
  none,
  success,
  noStudy,
  haveStudy,
}

class OctoBeatDeviceViewState {
  ScreenState screenState;
  String? phoneNumber;
  String? deviceId;
  String? pateintId;
  ECG0StudyByPatientInfo? study;

  OctoBeatDeviceViewState({
    this.screenState = ScreenState.loading,
    this.phoneNumber,
    this.pateintId,
    this.deviceId,
    this.study,
  });

  OctoBeatDeviceViewState copyWith(
      {ScreenState? screenState,
      String? phoneNumber,
      String? deviceId,
      String? pateintId,
      ECG0StudyByPatientInfo? study}) {
    return OctoBeatDeviceViewState(
      screenState: screenState ?? this.screenState,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pateintId: pateintId ?? this.pateintId,
      deviceId: deviceId ?? this.deviceId,
      study: study ?? this.study,
    );
  }
}
