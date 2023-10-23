import 'dart:async';
import 'package:octo360/application/utils/permission/permission_utils.dart';
import 'package:octo360/data/local/bridge/octo_beat/octo_beat_plugin_handler.dart';
import 'package:octo360/domain/bloc/base/base_cubit.dart';
import 'package:octo360/domain/model/global/global_state.dart';
import 'package:octo360/domain/model/global/reload_param.dart';
import 'package:octo360/l10n/locale_enum.dart';
import 'package:octo_beat_plugin/octo_beat_service_plugin.dart';

class GlobalBloc extends BaseCubit<GlobalState> {
  GlobalBloc() : super(GlobalState());
  static LocaleEnum currentLocaleStatic = LocaleEnum.vi;
  final _reloadStream = StreamController<ReloadParam>.broadcast();

  @override
  Future<void> close() {
    _reloadStream.close();
    return super.close();
  }

  //************************ GLOBAL CHANGES ****************************** */
  Stream<ReloadParam> listenGlobalChanges() {
    return _reloadStream.stream;
  }

  void notifyGlobalChanges(ReloadParam param) {
    return _reloadStream.add(param);
  }
  //*********************************************************************** */
}

//INIT FORCEGROUND SERVICE IN ANDROID - USING WHEN FIRST LAUNCH TABS SCREEN
extension GlobalBlocBackgroundInitExt on GlobalBloc {
  void initForceGroundService() async {
    //OCTO BEAT DEVICE
    await OctoBeatServicePlugin.startService();
    await OctoBeatServicePlugin.initializeHeadlessService(octoBeatHeadlessTask);

    //REQUEST BATTERY OPTIMIZATION IN ORDER TO RESTRICT DOZE MODE
    await PermissionUtils.requestIgnoreBatteryOptimizationsPermission();
  }
}
