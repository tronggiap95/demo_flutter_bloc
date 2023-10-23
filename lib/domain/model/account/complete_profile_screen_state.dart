import 'package:octo360/application/enum/screen/base_screen_state_enum.dart';

class CompleteProfileScreenState {
  String? firstNameError;
  String? lastNameError;
  String screenError;
  String lastName;
  String firstName;
  bool? isEnable;
  bool? isLoading;

  BaseScreenState screenState;
  CompleteProfileScreenState({
    this.firstNameError,
    this.lastNameError,
    this.screenError = '',
    this.lastName = '',
    this.firstName = '',
    this.isEnable,
    this.isLoading,
    this.screenState = BaseScreenState.none,
  });

  CompleteProfileScreenState copyWith({
    String? firstNameError,
    String? lastNameError,
    String? screenError,
    String? lastName,
    String? firstName,
    bool? isEnable,
    bool? isLoading,
    BaseScreenState? screenState,
  }) {
    return CompleteProfileScreenState(
      firstNameError: firstNameError ?? this.firstNameError,
      lastNameError: lastNameError ?? this.lastNameError,
      screenError: screenError ?? this.screenError,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      isEnable: isEnable ?? this.isEnable,
      isLoading: isLoading ?? this.isLoading,
      screenState: screenState ?? this.screenState,
    );
  }
}
