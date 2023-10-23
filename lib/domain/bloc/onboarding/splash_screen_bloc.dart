import 'package:flutter/material.dart';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/data/di/factory_manager.dart';
import 'package:octo360/domain/bloc/base/base_cubit.dart';
import 'package:octo360/domain/model/onboarding/splash_screen_state.dart';
import 'package:octo360/presentation/navigation/app_state/app_state_helper.dart';

class SplashScreenBloc extends BaseCubit<SplashScreenState> {
  SplashScreenBloc() : super(SplashScreenState());

  void setUpAppConfiguration() async {
    try {
      //Config aws cognito
      await FactoryManager.provideAuthenRepo().configureAmplify();
      await AppStateHelper.handleInitialization();
    } catch (error) {
      Log.e("handleInitialization $error");
    }
  }
}
