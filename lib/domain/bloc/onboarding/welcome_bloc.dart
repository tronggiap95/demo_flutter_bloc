import 'package:octo360/domain/bloc/base/base_cubit.dart';
import 'package:octo360/domain/model/onboarding/welcome_screen_state.dart';

class WelcomeBloc extends BaseCubit<WelcomeScreenState> {
  WelcomeBloc() : super(WelcomeScreenState());
}
