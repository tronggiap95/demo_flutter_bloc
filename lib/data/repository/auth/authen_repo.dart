import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:octo360/data/remote/amplify/auth_datasource.dart';

abstract class AuthenRepo {
  Future<void> configureAmplify();
  Future<bool> isSignedIn();
  Future<String> getUserToken();

  ///@Param: phoneNumber: +84559101234
  ///Sign-up will be auto confirmed and verified
  Future<void> signUpCustomFlow({required String phoneNumber});

  ///@Param: phoneNumber: +84559101234
  Future<void> signInCustomFlow({required String phoneNumber});

  ///Choose the method to send OTP code: SMS or EMAIL
  Future<void> chooseAuthMethod(AuthOtpMethod method);

  ///SMS code
  Future<void> confirmSignIn({required String code});

  Future<SignOutResult> signout({bool isGlobalSignOut = false});
}
