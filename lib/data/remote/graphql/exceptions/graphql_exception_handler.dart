// ignore_for_file: constant_identifier_names
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:octo360/data/model/failure.dart';

enum DataSource {
  SUCCESS,
  NO_CONTENT,
  BAD_REQUEST,
  FORBIDDEN,
  UNAUTHORISED,
  NOT_FOUND,
  INTERNAL_SERVER_ERROR,
  CONNECT_TIMEOUT,
  CANCEL,
  RECEIVE_TIMEOUT,
  SEND_TIMEOUT,
  CACHE_ERROR,
  NO_INTERNET_CONNECTION,
  DEFAULT
}

class GraphQLExceptionHandler {
  static Failure handleException(dynamic exception) {
    if (exception is SessionExpiredException) {
      return Failure(GraphQLResponseCode.SESSION_SIGN_IN_EXPIRED,
          GraphQLResponseMessage.SESSION_SIGN_IN_EXPIRED);
    }
    if (exception is AuthNotAuthorizedException) {
      return Failure(GraphQLResponseCode.UNAUTHORISED,
          GraphQLResponseMessage.UNAUTHORISED);
    }
    if (exception is OperationException) {
      if (exception.linkException is HttpLinkServerException) {
        HttpLinkServerException httpLink =
            exception.linkException as HttpLinkServerException;

        switch (httpLink.response.statusCode) {
          case HttpStatus.badRequest:
            return DataSource.BAD_REQUEST.getFailure();
          case HttpStatus.unauthorized:
            return DataSource.UNAUTHORISED.getFailure();
          case HttpStatus.notFound:
            return DataSource.NOT_FOUND.getFailure();
          case HttpStatus.forbidden:
            return DataSource.FORBIDDEN.getFailure();
          case HttpStatus.internalServerError:
            return DataSource.INTERNAL_SERVER_ERROR.getFailure();
          default:
            return DataSource.DEFAULT.getFailure();
        }
      }

      // if (exception.linkException is NetworkException) {
      //   return DataSource.NO_INTERNET_CONNECTION.getFailure();
      // }

      return DataSource.DEFAULT.getFailure();
    } else if (exception is String) {
      return Failure(GraphQLResponseCode.DEFAULT, exception);
    } else if (exception is Failure) {
      return exception;
    } else if (exception is Exception) {
      return Failure(GraphQLResponseCode.DEFAULT, exception.toString());
    } else {
      return DataSource.DEFAULT.getFailure();
    }
  }
}

extension DataSourceExtension on DataSource {
  Failure getFailure() {
    switch (this) {
      case DataSource.BAD_REQUEST:
        return Failure(GraphQLResponseCode.BAD_REQUEST,
            GraphQLResponseMessage.BAD_REQUEST);
      case DataSource.FORBIDDEN:
        return Failure(
            GraphQLResponseCode.FORBIDDEN, GraphQLResponseMessage.FORBIDDEN);
      case DataSource.UNAUTHORISED:
        return Failure(GraphQLResponseCode.UNAUTHORISED,
            GraphQLResponseMessage.UNAUTHORISED);
      case DataSource.NOT_FOUND:
        return Failure(
            GraphQLResponseCode.NOT_FOUND, GraphQLResponseMessage.NOT_FOUND);
      case DataSource.INTERNAL_SERVER_ERROR:
        return Failure(GraphQLResponseCode.INTERNAL_SERVER_ERROR,
            GraphQLResponseMessage.INTERNAL_SERVER_ERROR);
      case DataSource.CONNECT_TIMEOUT:
        return Failure(GraphQLResponseCode.CONNECT_TIMEOUT,
            GraphQLResponseMessage.CONNECT_TIMEOUT);
      case DataSource.CANCEL:
        return Failure(
            GraphQLResponseCode.CANCEL, GraphQLResponseMessage.CANCEL);
      case DataSource.RECEIVE_TIMEOUT:
        return Failure(GraphQLResponseCode.RECEIVE_TIMEOUT,
            GraphQLResponseMessage.RECEIVE_TIMEOUT);
      case DataSource.SEND_TIMEOUT:
        return Failure(GraphQLResponseCode.SEND_TIMEOUT,
            GraphQLResponseMessage.SEND_TIMEOUT);
      case DataSource.CACHE_ERROR:
        return Failure(GraphQLResponseCode.CACHE_ERROR,
            GraphQLResponseMessage.CACHE_ERROR);
      case DataSource.NO_INTERNET_CONNECTION:
        return Failure(GraphQLResponseCode.NO_INTERNET_CONNECTION,
            GraphQLResponseMessage.NO_INTERNET_CONNECTION);
      case DataSource.DEFAULT:
        return Failure(
            GraphQLResponseCode.DEFAULT, GraphQLResponseMessage.DEFAULT);
      default:
        return Failure(
            GraphQLResponseCode.DEFAULT, GraphQLResponseMessage.DEFAULT);
    }
  }
}

class GraphQLResponseCode {
  // API status codes
  static const int SUCCESS = HttpStatus.ok; // success with data
  static const int NO_CONTENT = HttpStatus.noContent; // success with no content
  static const int BAD_REQUEST =
      HttpStatus.badRequest; // failure, api rejected the request
  static const int FORBIDDEN =
      HttpStatus.forbidden; // failure, api rejected the request
  static const int UNAUTHORISED =
      HttpStatus.unauthorized; // failure user is not authorised
  static const int NOT_FOUND =
      HttpStatus.notFound; // failure, api url is not correct and not found
  static const int INTERNAL_SERVER_ERROR = HttpStatus.internalServerError;
  static const int PRECONDITION_FAILED = 412;

  // local status code
  static const int DEFAULT = -10;
  static const int CONNECT_TIMEOUT = -20;
  static const int CANCEL = -30;
  static const int RECEIVE_TIMEOUT = -40;
  static const int SEND_TIMEOUT = -50;
  static const int CACHE_ERROR = -6;
  static const int NO_INTERNET_CONNECTION = -7;
  static const int SESSION_SIGN_IN_EXPIRED = -8;
}

class GraphQLResponseMessage {
  // API status codes
  static const String SUCCESS = "success"; // success with data
  static const String NO_CONTENT =
      "success with no content"; // success with no content
  static const String BAD_REQUEST =
      "Bad request, try again later"; // failure, api rejected the request
  static const String FORBIDDEN =
      "forbidden request, try again later"; // failure, api rejected the request
  static const String UNAUTHORISED =
      "user is unauthorised, try again later"; // failure user is not authorised
  static const String NOT_FOUND =
      "Url is not found, try again later"; // failure, api url is not correct and not found
  static const String INTERNAL_SERVER_ERROR =
      "some thing went wrong, try again later"; // failure, crash happened in server side

  // local status code
  static const String DEFAULT = "some thing went wrong, try again later";
  static const String CONNECT_TIMEOUT = "time out error, try again later";
  static const String CANCEL = "request was cancelled, try again later";
  static const String RECEIVE_TIMEOUT = "time out error, try again later";
  static const String SEND_TIMEOUT = "time out error, try again later";
  static const String CACHE_ERROR = "Cache error, try again later";
  static const String NO_INTERNET_CONNECTION =
      "Please check your internet connection";
  static const String SESSION_SIGN_IN_EXPIRED =
      'For security reasons, your connection times out after you\'ve been inactive for a while. Please log in again.';
}
