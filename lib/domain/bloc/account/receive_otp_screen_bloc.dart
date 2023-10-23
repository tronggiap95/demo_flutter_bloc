import 'dart:async';

import 'package:octo360/application/enum/screen/base_screen_state_enum.dart';
import 'package:octo360/application/utils/internet/internet_connection.dart';
import 'package:octo360/application/utils/string/validation_utils.dart';
import 'package:octo360/data/remote/amplify/auth_datasource.dart';
import 'package:octo360/data/repository/auth/authen_repo.dart';
import 'package:octo360/domain/bloc/base/base_cubit.dart';
import 'package:octo360/domain/model/account/receive_otp_screen_state.dart';
import 'package:octo360/presentation/navigation/app_state/app_state_helper.dart';
import 'package:octo360/src/strings/string_manager.dart';

class ReceiveOtpScreenBloc extends BaseCubit<ReceiveOtpScreenState> {
  ReceiveOtpScreenBloc(
    this._authenRepo,
  ) : super(ReceiveOtpScreenState());

  final AuthenRepo _authenRepo;
  Timer? _countDownTimer;
  final _timePeriodicDefault = 1;

  void initState(String? phoneNumber, String? countryCode) {
    _initCountdownTimer();
    emit(state.copyWith(phoneNumber: phoneNumber, countryCode: countryCode));
  }

  @override
  Future<void> close() {
    cancelTimer();
    return super.close();
  }

  void confirm() async {
    try {
      if (state.screenState == BaseScreenState.loading) {
        return;
      }
      if (!(await InternetConnection.hasInternetConnection())) {
        emit(state.copyWith(
            screenState: BaseScreenState.noInternet,
            inputError: StringsApp.noInternetConnectionTryAgain));
        return;
      }
      emit(state.copyWith(screenState: BaseScreenState.loading));
      await _authenRepo.confirmSignIn(code: state.otp);
      await AppStateHelper.handleInitialization();
      emit(state.copyWith(screenState: BaseScreenState.success));
    } catch (error) {
      emit(state.copyWith(
          screenState: BaseScreenState.failed,
          inputError: StringsApp.otpCodeIncorrect));
    }
  }

  void resendOtp() async {
    try {
      if (!(await InternetConnection.hasInternetConnection())) {
        emit(state.copyWith(
            screenState: BaseScreenState.noInternet,
            inputError: StringsApp.noInternetConnectionTryAgain));
        return;
      }
      _initCountdownTimer();
      final phoneNumberFormatted = await _getPhoneNumberFormatted();
      //SignIn with Custom Flow
      await _authenRepo.signInCustomFlow(phoneNumber: phoneNumberFormatted);
      //Choose Method to send OTP code
      await _authenRepo.chooseAuthMethod(AuthOtpMethod.sms);
    } catch (error) {
      cancelTimer();
      emit(state.copyWith(
          countDownTime: 0,
          screenState: BaseScreenState.failed,
          screenError: StringsApp.somethingWentWrongTryAgain));
    }
  }

  void _initCountdownTimer() {
    const initTimeDefault = 60;
    if (_countDownTimer?.isActive ?? false) _countDownTimer!.cancel();
    emit(state.copyWith(countDownTime: initTimeDefault));
    _countDownTimer = Timer.periodic(Duration(seconds: _timePeriodicDefault),
        (_) => _countdownTimerHandler());
  }

  void _countdownTimerHandler() {
    int secondsCountdown = state.countDownTime - _timePeriodicDefault;
    if (secondsCountdown <= 0) _countDownTimer!.cancel();
    emit(state.copyWith(countDownTime: secondsCountdown));
  }

  void cancelTimer() {
    _countDownTimer?.cancel();
  }

  Future<String> _getPhoneNumberFormatted() async {
    return ValidationUtils.getFormattedPhoneNumber(
        state.phoneNumber, state.countryCode);
  }

  bool validateOtp(String otp) {
    return ValidationUtils.isValidOTP(otp);
  }

  void setInputError(String? error) {
    final temp = state.copyWith();
    temp.inputError = error;
    emit(temp);
  }

  void setOtp(String otp) {
    emit(state.copyWith(otp: otp, isEnable: validateOtp(otp)));
  }

  void setShowKeyboard(bool isShow) {
    state.shouldShowKeyboard = isShow;
  }

  String displayPhoneNumberStr() {
    return '(${state.countryCode}) ${state.phoneNumber.replaceFirst(r'0', '')}';
  }

  void resetScreenState() {
    emit(state.copyWith(screenState: BaseScreenState.none, screenError: ''));
  }
}
