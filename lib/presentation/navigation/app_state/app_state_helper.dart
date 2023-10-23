import 'dart:async';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/data/di/factory_manager.dart';
import 'package:octo360/data/model/graphql/model/user/user.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';

enum AppState {
  notAuthorized,
  authorized,
  notCompletedProfile,
  completedProfile,
}

class AppStateHelper {
  static handleInitialization() async {
    final state = await _getInitialState();
    handleState(state);
  }

  ///Need to handle exception
  static void handleState(
    AppState state,
  ) {
    try {
      final context = NavigationApp.navigatorKey.currentContext!;
      switch (state) {
        case AppState.notAuthorized:
          NavigationApp.replaceWith(context, Routes.welcomeScreenRoute);
          break;
        case AppState.notCompletedProfile:
          NavigationApp.replaceWith(context, Routes.completeProfileScreenRoute);
          break;
        case AppState.completedProfile:
          NavigationApp.replaceWith(context, Routes.octoBeatDeviceViewRoute);
          break;
        default:
          break;
      }
    } catch (error) {
      Log.e("handleState $error");
      rethrow;
    }
  }

  static Future<AppState> _getInitialState() async {
    try {
      //CHECK SIGNED IN
      final isSignedIn = await _isSignedIn();
      if (!isSignedIn) {
        return AppState.notAuthorized;
      }

      //CHECK COMPLETED PROFILE
      final result = await _getUserProfile();
      if (!(result.isProfileCompleted ?? false)) {
        return AppState.notCompletedProfile;
      }

      return AppState.completedProfile;
    } catch (error) {
      Log.e('_getInititalState has error: $error');
      rethrow;
    }
  }

  ///Fetch User Profile and Insert to userDomain of Global repo
  static Future<User> _getUserProfile() async {
    final userRepo = FactoryManager.provideGraphQlUserRepo();
    return await userRepo.getProfile(isPrintLog: true);
  }

  static Future<bool> _isSignedIn() async {
    final authRepo = FactoryManager.provideAuthenRepo();
    final isSignedIn = await authRepo.isSignedIn();
    return isSignedIn;
  }
}
