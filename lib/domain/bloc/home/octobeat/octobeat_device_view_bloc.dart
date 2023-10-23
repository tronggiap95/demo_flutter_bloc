import 'dart:async';

import 'package:octo360/data/di/factory_manager.dart';
import 'package:octo360/data/local/share_pref/shared_pref.dart';
import 'package:octo360/data/model/graphql/request/ecg0_study_by_patient_info_filter/ecg0_study_by_patient_info_filter.dart';
import 'package:octo360/data/model/graphql/response/ecg0_study_patient_info/ecg0_study_patient_info.dart';
import 'package:octo360/data/remote/socketio/octobeat/socket_octobeat_device_handler.dart';
import 'package:octo360/data/remote/socketio/socketio_client.dart';
import 'package:octo360/domain/bloc/base/base_cubit.dart';
import 'package:octo360/domain/model/home/octobeat/octobeat_device_view_state.dart';
import 'package:octo_beat_plugin/connection/octo_beat_connection_plugin.dart';
import 'package:octo_beat_plugin/octo_beat_plugin.dart';

class OctoBeatDeviceViewBloc extends BaseCubit<OctoBeatDeviceViewState> {
  OctoBeatDeviceViewBloc() : super(OctoBeatDeviceViewState());
  StreamSubscription<SocketData>? _socketSubscription;

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    return super.close();
  }

  void initState() async {
    _initSocket();
    _getData();
  }

  void _getData() async {
    final device = await OctoBeatPlugin.getDeviceInfo();
    if (device != null) {
      emit(state.copyWith(screenState: ScreenState.haveStudy));
      return;
    }
    final globalRepo = FactoryManager.provideGlobalRepo();
    final patientId = state.pateintId ?? globalRepo.userDomain?.id ?? '';
    final phoneNumber = state.phoneNumber ??
        globalRepo.userDomain?.contactInfo?.phoneNumber ??
        '';
    final rs =
        await _queryOctoBeatStudy(patientId: patientId, phone: phoneNumber);

    if (rs == null || rs.status == "Done") {
      final hasShowCompletedDialog =
          await SharedPref.getHasShowCompletedStudyDialog();

      if (!hasShowCompletedDialog && rs != null) {
        emit(
          state.copyWith(
            screenState: ScreenState.haveStudy,
            pateintId: patientId,
            phoneNumber: phoneNumber,
            deviceId: rs.deviceId,
            study: rs,
          ),
        );
        return;
      }

      emit(state.copyWith(
        screenState: ScreenState.noStudy,
        pateintId: patientId,
        phoneNumber: phoneNumber,
      ));
      return;
    }
    emit(state.copyWith(
      screenState: ScreenState.haveStudy,
      pateintId: patientId,
      phoneNumber: phoneNumber,
      deviceId: rs.deviceId,
      study: rs,
    ));
  }

  void _initSocket() async {
    await _socketSubscription?.cancel();
    _socketSubscription = FactoryManager.provideSocketOctoBeatDevice()
        .listenEvents()
        ?.listen((event) {
      final type = OctoBeatDeviceEvent.from(event.event);
      switch (type) {
        case OctoBeatDeviceEvent.studyEvent:
          final study = ECG0StudyByPatientInfo.fromJson(event.data);
          _handleStudyStatus(study);
          break;
        default:
      }
    });
  }

  void _handleStudyStatus(ECG0StudyByPatientInfo study) async {
    if (state.screenState == ScreenState.noStudy && study.status != "Done") {
      emit(state.copyWith(
        screenState: ScreenState.haveStudy,
        study: study,
        deviceId: study.deviceId,
      ));
    }
  }

  void onDisconnectedDevice() async {
    emit(state.copyWith(screenState: ScreenState.loading));
    await OctoBeatConnectionPlugin.deleteDevice();
    Future.delayed(const Duration(seconds: 1), () {
      initState();
    });
  }

  Future<ECG0StudyByPatientInfo?> _queryOctoBeatStudy(
      {required String phone, required String patientId}) async {
    final graphqlRepo = FactoryManager.provideGraphQlOctoBeatRepo();
    final study = await graphqlRepo.getStudyByPatientInfo(
      filter: ECG00StudyByPatientInfoFilter(
        patientId: patientId,
        phone: phone,
      ),
      isPrintLog: true,
    );
    return study;
  }
}
