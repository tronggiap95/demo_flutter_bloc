import 'package:octo360/application/enum/screen/base_screen_state_enum.dart';
import 'package:octo360/application/utils/date_time/date_time_utils.dart';
import 'package:octo360/application/utils/internet/internet_connection.dart';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/application/utils/string/validation_utils.dart';
import 'package:octo360/data/model/failure.dart';
import 'package:octo360/data/remote/amplify/auth_datasource.dart';
import 'package:octo360/data/remote/amplify/auth_error_handler.dart';
import 'package:octo360/data/repository/auth/authen_repo.dart';
import 'package:octo360/domain/bloc/base/base_cubit.dart';
import 'package:octo360/domain/model/account/log_in_screen_state.dart';
import 'package:octo360/src/strings/string_manager.dart';

class LogInScreenBloc extends BaseCubit<LogInScreenState> {
  LogInScreenBloc(
    this._authenRepo,
  ) : super(LogInScreenState());

  final AuthenRepo _authenRepo;

  void initState() {
    final countryCode = DateTimeUtils.currentCountryCode();
    emit(state.copyWith(countryCode: countryCode));
  }

  void continueWithPhoneNumber() async {
    try {
      if (state.screenState == BaseScreenState.loading) {
        return;
      }

      if (!(await InternetConnection.hasInternetConnection())) {
        emit(state.copyWith(
            screenState: BaseScreenState.noInternet,
            screenError: StringsApp.noInternetConnectionTryAgain));
        return;
      }

      // Validate phone number
      if (!(await validatePhoneNumber())) {
        emit(state.copyWith(
            screenState: BaseScreenState.none,
            inputError: StringsApp.invalidPhoneNumber));
        return;
      }

      //Login Amplify
      emit(state.copyWith(screenState: BaseScreenState.loading));
      final phoneNumber = await getPhoneNumberFormatted();
      await _login(phoneNumber: phoneNumber);

      emit(state.copyWith(screenState: BaseScreenState.success));
    } catch (error) {
      Log.e("continueWithPhoneNumber $error");
      emit(state.copyWith(
          screenState: BaseScreenState.failed,
          screenError: StringsApp.somethingWentWrongTryAgain));
    }
  }

  Future<void> _login({required String phoneNumber}) async {
    try {
      await _signout();
      //SignIn with Custom Flow
      await _authenRepo.signInCustomFlow(phoneNumber: phoneNumber);
      //Choose Method to send OTP code
      await _authenRepo.chooseAuthMethod(AuthOtpMethod.sms);
    } catch (error) {
      if (error is Failure && error.code == AuthResponseCode.USER_NOT_FOUND) {
        await _signUp(phoneNumber: phoneNumber);
        return;
      }
      rethrow;
    }
  }

  Future<void> _signout() async {
    try {
      //SignIn with Custom Flow
      await _authenRepo.signout();
    } catch (error) {}
  }

  Future<void> _signUp({required String phoneNumber}) async {
    try {
      //For SMS Passwodless, BE will auto verify and confirmed when signing up.
      //After that needs to call signIn to get OTP code
      await _authenRepo.signUpCustomFlow(phoneNumber: phoneNumber);
      await _authenRepo.signInCustomFlow(phoneNumber: phoneNumber);
      await _authenRepo.chooseAuthMethod(AuthOtpMethod.sms);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> getPhoneNumberFormatted() async {
    final regionCode = DateTimeUtils.currentRegionCode();
    return ValidationUtils.getFormattedPhoneNumber(
        state.phoneNumber, regionCode);
  }

  Future<bool> validatePhoneNumber() async {
    final regionCode = DateTimeUtils.currentRegionCode();
    return ValidationUtils.validatePhoneNumber(state.phoneNumber, regionCode);
  }

  void setPhoneNumber(String value) {
    final temp = state.copyWith();
    temp.phoneNumber = value;
    temp.isEnable = value.isNotEmpty;
    temp.inputError = null;
    emit(temp);
  }

  void resetScreenError() {
    final temp = state.copyWith();
    temp.screenError = '';
    temp.screenState = BaseScreenState.none;
    emit(temp);
  }
}
