import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:octo360/data/remote/amplify/auth_datasource.dart';
import 'package:octo360/data/repository/auth/authen_repo.dart';

class AuthenRepoImpl extends AuthenRepo {
  @override
  Future<void> configureAmplify() {
    return AuthDatasource.configureAmplify();
  }

  @override
  Future<bool> isSignedIn() {
    return AuthDatasource.isSignedIn();
  }

  @override
  Future<String> getUserToken() {
    return AuthDatasource.getUserToken();
  }

  @override
  Future<void> signInCustomFlow({required String phoneNumber}) {
    return AuthDatasource.signInCustomFlow(phoneNumber: phoneNumber);
  }

  @override
  Future<void> chooseAuthMethod(AuthOtpMethod method) {
    return AuthDatasource.chooseAuthMethod(method);
  }

  @override
  Future<void> confirmSignIn({required String code}) {
    return AuthDatasource.confirmSignIn(code: code);
  }

  @override
  Future<void> signUpCustomFlow({required String phoneNumber}) {
    return AuthDatasource.signUpCustomFlow(phoneNumber: phoneNumber);
  }

  @override
  Future<SignOutResult> signout({bool isGlobalSignOut = false}) {
    return AuthDatasource.signout(isGlobalSignOut: false);
  }
}
