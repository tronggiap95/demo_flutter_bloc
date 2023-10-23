import 'package:octo360/application/enum/screen/base_screen_state_enum.dart';

class LogInScreenState {
  String? inputError;
  String screenError;
  String phoneNumber;
  String countryCode;
  bool isEnable;

  BaseScreenState screenState;
  LogInScreenState({
    this.inputError,
    this.screenError = '',
    this.phoneNumber = '',
    this.countryCode = '+84',
    this.isEnable = false,
    this.screenState = BaseScreenState.none,
  });

  LogInScreenState copyWith({
    String? inputError,
    String? screenError,
    String? phoneNumber,
    String? countryCode,
    bool? isEnable,
    BaseScreenState? screenState,
  }) {
    return LogInScreenState(
      inputError: inputError ?? this.inputError,
      screenError: screenError ?? this.screenError,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      isEnable: isEnable ?? this.isEnable,
      screenState: screenState ?? this.screenState,
    );
  }
}
