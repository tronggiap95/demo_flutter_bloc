import 'package:octo360/application/enum/screen/base_screen_state_enum.dart';

class ReceiveOtpScreenState {
  String? inputError;
  String screenError;
  String otp;
  int countDownTime;
  bool isEnable;
  bool shouldShowKeyboard;
  String phoneNumber;
  String countryCode;
  BaseScreenState screenState;

  ReceiveOtpScreenState({
    this.inputError,
    this.screenError = '',
    this.otp = '',
    this.countDownTime = 59,
    this.isEnable = false,
    this.shouldShowKeyboard = false,
    this.phoneNumber = '',
    this.countryCode = '+84',
    this.screenState = BaseScreenState.none,
  });

  ReceiveOtpScreenState copyWith({
    String? inputError,
    String? screenError,
    String? otp,
    int? countDownTime,
    bool? isEnable,
    bool? shouldShowKeyboard,
    String? phoneNumber,
    String? countryCode,
    BaseScreenState? screenState,
  }) {
    return ReceiveOtpScreenState(
      inputError: inputError ?? this.inputError,
      screenError: screenError ?? this.screenError,
      otp: otp ?? this.otp,
      countDownTime: countDownTime ?? this.countDownTime,
      isEnable: isEnable ?? this.isEnable,
      shouldShowKeyboard: shouldShowKeyboard ?? this.shouldShowKeyboard,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      screenState: screenState ?? this.screenState,
    );
  }
}
