import 'package:octo360/application/enum/dialog_state_enum.dart';
import 'package:octo360/application/enum/pairing_state.dart';

class OctobeatPairDeviceState {
  PairingState? pairingState;
  DialogState? dialogState;
  String? deviceId;
  String? deviceAddress;

  OctobeatPairDeviceState({
    this.pairingState = PairingState.scanning,
    this.dialogState = DialogState.none,
    this.deviceId,
    this.deviceAddress,
  });

  OctobeatPairDeviceState copyWith({
    PairingState? pairingState,
    DialogState? dialogState,
    String? deviceId,
    String? deviceAddress,
  }) {
    return OctobeatPairDeviceState(
      pairingState: pairingState ?? this.pairingState,
      dialogState: dialogState ?? this.dialogState,
      deviceId: deviceId ?? this.deviceId,
      deviceAddress: deviceAddress ?? this.deviceAddress,
    );
  }
}
