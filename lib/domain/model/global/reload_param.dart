import 'package:octo360/domain/model/global/global_state.dart';

class ReloadParam {
  ReloadState reloadState;
  dynamic reloadParams;
  bool forceReload;

  ReloadParam({
    this.reloadState = ReloadState.none,
    this.reloadParams,
    this.forceReload = false,
  });

  ReloadParam copyWith({
    ReloadState? reloadState,
    dynamic reloadParams,
    bool? forceReload,
  }) {
    return ReloadParam(
      reloadState: reloadState ?? this.reloadState,
      reloadParams: reloadParams ?? this.reloadParams,
      forceReload: forceReload ?? this.forceReload,
    );
  }
}
