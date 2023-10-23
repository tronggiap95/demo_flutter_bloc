import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:octo360/application/env/env_config.dart';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/data/remote/amplify/auth_error_handler.dart';

enum AuthOtpMethod {
  sms('SMS_OTP_VERIFIER'),
  email('EMAIL_OTP_VERIFIER');

  final String value;

  const AuthOtpMethod(this.value);
}

class AuthDatasource {
  static Future<void> configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      // Add the following line to add Auth plugin to your app.
      await Amplify.addPlugins([auth]);
      // call Amplify.configure to use the initialized categories in your app
      await Amplify.configure(EnvConfigApp.getEnv().awsConfig);
    } on Exception catch (error) {
      Log.e(error);
    }
  }

  static Future<bool> isSignedIn() async {
    final result = await Amplify.Auth.fetchAuthSession();
    return result.isSignedIn;
  }

  static Future<String> getUserToken() async {
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final result = await cognitoPlugin.fetchAuthSession(
        options: const FetchAuthSessionOptions(forceRefresh: true));
    return result.userPoolTokensResult.value.accessToken.raw;
  }

  ///@Param: phoneNumber: +84559101234
  ///Sign-up will be auto confirmed and verified
  static Future<void> signUpCustomFlow({required String phoneNumber}) async {
    try {
      final userAttributes = <AuthUserAttributeKey, String>{
        AuthUserAttributeKey.phoneNumber: phoneNumber,
      };

      //Since AWS doesn’t support passwordless authentication
      //it requires us to provide a password.
      //So, we can use a random dummy password.
      final randomPass = DateTime.now().toString();

      final result = await Amplify.Auth.signUp(
        username: phoneNumber,
        password: randomPass,
        options: SignUpOptions(userAttributes: userAttributes),
      );

      if (!result.isSignUpComplete) {
        final exception = AuthErrorHandler.parseCustomError(
            result.nextStep.additionalInfo['errorCode']);
        throw AuthErrorHandler.getError(exception);
      }
    } catch (error) {
      Log.e("signUpCustomFlow $error");
      throw AuthErrorHandler.getError(error);
    }
  }

  ///@Param: phoneNumber: +84559101234
  static Future<void> signInCustomFlow({required String phoneNumber}) async {
    try {
      final result = await Amplify.Auth.signIn(
          username: phoneNumber,
          options: const SignInOptions(
            pluginOptions: CognitoSignInPluginOptions(
              authFlowType: AuthenticationFlowType.customAuthWithoutSrp,
            ),
          ));
      final exception = AuthErrorHandler.parseCustomError(
          result.nextStep.additionalInfo['errorCode']);
      if (exception != null) {
        throw AuthErrorHandler.getError(exception);
      }
    } catch (error) {
      Log.e("signInCustomFlow $error");
      throw AuthErrorHandler.getError(error);
    }
  }

  static Future<void> chooseAuthMethod(AuthOtpMethod method) async {
    try {
      final result = await Amplify.Auth.confirmSignIn(
          confirmationValue: 'OTP-METHOD',
          options: ConfirmSignInOptions(
            pluginOptions: CognitoConfirmSignInPluginOptions(
              clientMetadata: {'method': method.value},
            ),
          ));

      final exception = AuthErrorHandler.parseCustomError(
          result.nextStep.additionalInfo['errorCode']);
      if (exception != null) {
        throw AuthErrorHandler.getError(exception);
      }
    } catch (error) {
      Log.e("confirmSignIn $error");
      throw AuthErrorHandler.getError(error);
    }
  }

  ///SMS code
  static Future<void> confirmSignIn({required String code}) async {
    try {
      final result = await Amplify.Auth.confirmSignIn(
          confirmationValue: code,
          options: ConfirmSignInOptions(
            pluginOptions: CognitoConfirmSignInPluginOptions(
              clientMetadata: {'method': AuthOtpMethod.sms.value},
            ),
          ));

      if (!result.isSignedIn) {
        final exception = AuthErrorHandler.parseCustomError(
            result.nextStep.additionalInfo['errorCode']);
        throw AuthErrorHandler.getError(exception);
      }
    } catch (error) {
      Log.e("confirmSignIn $error");
      throw AuthErrorHandler.getError(error);
    }
  }

  static Future<SignOutResult> signout({bool isGlobalSignOut = false}) async {
    return await Amplify.Auth.signOut(
            options: SignOutOptions(globalSignOut: isGlobalSignOut))
        .timeout(const Duration(seconds: 5));
  }
}
