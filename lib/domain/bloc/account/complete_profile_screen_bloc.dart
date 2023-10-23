import 'package:octo360/application/enum/screen/base_screen_state_enum.dart';
import 'package:octo360/application/utils/internet/internet_connection.dart';
import 'package:octo360/data/model/graphql/request/update_profile_input/update_profile_input.dart';
import 'package:octo360/data/repository/graphql/graphql_user_repo.dart';
import 'package:octo360/domain/bloc/base/base_cubit.dart';
import 'package:octo360/domain/model/account/complete_profile_screen_state.dart';
import 'package:octo360/src/strings/string_manager.dart';

class CompleteProfileScreenBloc extends BaseCubit<CompleteProfileScreenState> {
  CompleteProfileScreenBloc(
    this._graphQlUserRepo,
  ) : super(CompleteProfileScreenState());

  final GraphQlUserRepo _graphQlUserRepo;

  void finish() async {
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

      emit(state.copyWith(isLoading: true));
      final firstName = state.firstName;
      final lastName = state.lastName;
      await _graphQlUserRepo.updateProfile(
          UpdateProfileInput(firstName: firstName, lastName: lastName));
      emit(state.copyWith(
        screenState: BaseScreenState.success,
      ));
    } catch (error) {
      emit(state.copyWith(
          screenState: BaseScreenState.failed,
          screenError: StringsApp.somethingWentWrongTryAgain));
    }
  }

  void setFirstName(String value) {
    emit(state.copyWith(firstName: value));
    validateField();
  }

  void setLastName(String value) {
    emit(state.copyWith(lastName: value));
    validateField();
  }

  void validateField() {
    if (state.firstName.isNotEmpty && state.lastName.isNotEmpty) {
      emit(state.copyWith(isEnable: true));
    } else {
      emit(state.copyWith(isEnable: false));
    }
  }

  void resetScreenError() {
    final temp = state.copyWith();
    temp.screenError = '';
    temp.screenState = BaseScreenState.none;
    emit(temp);
  }
}
