import 'package:flutter/material.dart';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/data/di/factory_manager.dart';
import 'package:octo360/domain/model/profile/user/user_domain.dart';

class GlobalRepo {
  UserDomain? userDomain;

  void _clearData() {
    userDomain = null;
  }

  Future<void> clearUserData() async {}

  Future<void> handleSignOut(BuildContext context) async {
    try {
      //clear global data
      _clearData();

      //Remove Octo device

      //Dispose socket

      //clear global state

      //Sign out
      final authRepo = FactoryManager.provideAuthenRepo();
      await authRepo.signout();
    } catch (error) {
      Log.e("[handleSignout] $error");
    }
  }
}
