// ignore_for_file: constant_identifier_names

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:octo360/data/model/failure.dart';

class AuthErrorHandler implements Exception {
  static Exception? parseCustomError(String? error) {
    if (error == null) {
      return null;
    }
    switch (error) {
      case 'TooManyRequestError':
        return const LimitExceededException('TooManyRequestError');
      case 'SMSError':
        return AuthErrorSource.DEFAULT.getFailure();
      default:
        return AuthErrorSource.DEFAULT.getFailure();
    }
  }

  static Failure getError(dynamic error) {
    if (error is UserNotFoundException) {
      return AuthErrorSource.USER_NOT_FOUND.getFailure();
    }

    if (error is UsernameExistsException) {
      return AuthErrorSource.USER_NAME_EXISTS.getFailure();
    }

    if (error is UserNotConfirmedException) {
      return AuthErrorSource.USER_NOT_CONFIRMED.getFailure();
    }

    if (error is CodeMismatchException) {
      return AuthErrorSource.CODE_MISMATCH.getFailure();
    }

    if (error is NotAuthorizedServiceException) {
      return AuthErrorSource.WRONG_USERNAME_OR_PASSWORD.getFailure();
    }

    if (error is LimitExceededException) {
      return AuthErrorSource.ATTEMPT_LIMIT_EXCEEDED.getFailure();
    }

    return AuthErrorSource.DEFAULT.getFailure();
  }
}

enum AuthErrorSource {
  DEFAULT,
  USER_NAME_EXISTS,
  USER_NOT_FOUND,
  USER_NOT_CONFIRMED,
  TOO_MANY_REQUESTS,
  TOO_MAY_FAILED_ATTEMPS,
  SESSION_EXPIRED,
  PASSWORD_RESET_REQUIRED,
  NOT_AUTHORIZED,
  LIMIT_EXCEEDED,
  INVALID_PARAMETER,
  INVALID_ACCOUNT_TYPE,
  CODE_MISMATCH,
  CODE_EXPIRED,
  WRONG_USERNAME_OR_PASSWORD,
  ATTEMPT_LIMIT_EXCEEDED,
}

extension AuthErrorException on AuthErrorSource {
  Failure getFailure() {
    switch (this) {
      case AuthErrorSource.DEFAULT:
        return Failure(AuthResponseCode.DEFAULT, AuthResponseMessage.DEFAULT);
      case AuthErrorSource.USER_NAME_EXISTS:
        return Failure(AuthResponseCode.USER_NAME_EXISTS,
            AuthResponseMessage.USER_NAME_EXISTS);
      case AuthErrorSource.USER_NOT_FOUND:
        return Failure(AuthResponseCode.USER_NOT_FOUND,
            AuthResponseMessage.USER_NOT_FOUND);
      case AuthErrorSource.USER_NOT_CONFIRMED:
        return Failure(AuthResponseCode.USER_NOT_CONFIRMED,
            AuthResponseMessage.USER_NOT_CONFIRMED);
      case AuthErrorSource.TOO_MANY_REQUESTS:
        return Failure(AuthResponseCode.TOO_MANY_REQUESTS,
            AuthResponseMessage.TOO_MANY_REQUESTS);
      case AuthErrorSource.TOO_MAY_FAILED_ATTEMPS:
        return Failure(AuthResponseCode.TOO_MAY_FAILED_ATTEMPS,
            AuthResponseMessage.TOO_MAY_FAILED_ATTEMPS);
      case AuthErrorSource.SESSION_EXPIRED:
        return Failure(AuthResponseCode.SESSION_EXPIRED,
            AuthResponseMessage.SESSION_EXPIRED);
      case AuthErrorSource.PASSWORD_RESET_REQUIRED:
        return Failure(AuthResponseCode.PASSWORD_RESET_REQUIRED,
            AuthResponseMessage.PASSWORD_RESET_REQUIRED);
      case AuthErrorSource.NOT_AUTHORIZED:
        return Failure(AuthResponseCode.NOT_AUTHORIZED,
            AuthResponseMessage.NOT_AUTHORIZED);
      case AuthErrorSource.LIMIT_EXCEEDED:
        return Failure(AuthResponseCode.LIMIT_EXCEEDED,
            AuthResponseMessage.LIMIT_EXCEEDED);
      case AuthErrorSource.INVALID_PARAMETER:
        return Failure(AuthResponseCode.INVALID_PARAMETER,
            AuthResponseMessage.INVALID_PARAMETER);
      case AuthErrorSource.INVALID_ACCOUNT_TYPE:
        return Failure(AuthResponseCode.INVALID_ACCOUNT_TYPE,
            AuthResponseMessage.INVALID_ACCOUNT_TYPE);
      case AuthErrorSource.CODE_MISMATCH:
        return Failure(
            AuthResponseCode.CODE_MISMATCH, AuthResponseMessage.CODE_MISMATCH);
      case AuthErrorSource.CODE_EXPIRED:
        return Failure(
            AuthResponseCode.CODE_EXPIRED, AuthResponseMessage.CODE_EXPIRED);
      case AuthErrorSource.WRONG_USERNAME_OR_PASSWORD:
        return Failure(AuthResponseCode.WRONG_USERNAME_OR_PASSWORD,
            AuthResponseMessage.WRONG_USERNAME_OR_PASSWORD);
      case AuthErrorSource.ATTEMPT_LIMIT_EXCEEDED:
        return Failure(AuthResponseCode.ATTEMPT_LIMIT_EXCEEDED,
            AuthResponseMessage.ATTEMPT_LIMIT_EXCEEDED);
    }
  }
}

class AuthResponseCode {
  static const int DEFAULT = -1;
  static const int USER_NAME_EXISTS = -2;
  static const int USER_NOT_FOUND = -3;
  static const int USER_NOT_CONFIRMED = -4;
  static const int TOO_MANY_REQUESTS = -5;
  static const int TOO_MAY_FAILED_ATTEMPS = -6;
  static const int SESSION_EXPIRED = -7;
  static const int PASSWORD_RESET_REQUIRED = -8;
  static const int NOT_AUTHORIZED = -9;
  static const int LIMIT_EXCEEDED = -10;
  static const int INVALID_PARAMETER = -11;
  static const int INVALID_ACCOUNT_TYPE = -12;
  static const int CODE_MISMATCH = -13;
  static const int CODE_EXPIRED = -14;
  static const int WRONG_USERNAME_OR_PASSWORD = -15;
  static const int ATTEMPT_LIMIT_EXCEEDED = -16;
}

class AuthResponseMessage {
  static const String DEFAULT = 'Failed authentication';
  static const String USER_NAME_EXISTS = 'User already exists';
  static const String USER_NOT_FOUND = 'User not found';
  static const String USER_NOT_CONFIRMED = 'User not confirmed yet';
  static const String TOO_MANY_REQUESTS = 'Too many requests';
  static const String TOO_MAY_FAILED_ATTEMPS = 'Too many failed attempt';
  static const String SESSION_EXPIRED = 'Session expired';
  static const String PASSWORD_RESET_REQUIRED = 'Need to reset password first';
  static const String NOT_AUTHORIZED = 'Not authorized';
  static const String LIMIT_EXCEEDED = 'Reach limit exceeded';
  static const String INVALID_PARAMETER = 'Invalid parameters';
  static const String INVALID_ACCOUNT_TYPE = 'Invalid account type';
  static const String CODE_MISMATCH = 'The code doens\'t match';
  static const String CODE_EXPIRED = 'The code is expired';
  static const String WRONG_USERNAME_OR_PASSWORD =
      'Incorrect username or password.';
  static const String ATTEMPT_LIMIT_EXCEEDED =
      'Number of allowed operation has exceeded.';
}
