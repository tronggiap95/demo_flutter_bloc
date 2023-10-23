import 'package:octo360/application/env/amplify_configuration.dart';

enum ENV {
  ALPHA,
  DELTA,
  STAGING,
  CUSTOMER;

  String get toStringValue {
    switch (this) {
      case ENV.ALPHA:
        return 'alpha';
      case ENV.DELTA:
        return 'delta';
      case ENV.STAGING:
        return 'staging';
      case ENV.CUSTOMER:
        return 'customer';
      default:
        return '';
    }
  }

  static ENV fromServer(String? value) {
    switch (value) {
      case 'alpha':
        return ENV.ALPHA;
      case 'delta':
        return ENV.DELTA;
      case 'staging':
        return ENV.STAGING;
      case 'customer':
        return ENV.CUSTOMER;
      default:
        return EnvConfigApp.env;
    }
  }
}

enum BUILD { DEBUG, RELEASE }

class EnvApp {
  final String endpoint;
  final String awsConfig;
  final String socketEndpoint;
  final String sentryEnpoint;
  // Used for messages feature
  final String appSyncEndpoint;

  EnvApp({
    required this.endpoint,
    required this.awsConfig,
    required this.socketEndpoint,
    required this.sentryEnpoint,
    required this.appSyncEndpoint,
  });
}

class EnvConfigApp {
  static var env = ENV.DELTA;
  static const build = BUILD.RELEASE;

  static EnvApp getEnv() {
    switch (env) {
      case ENV.ALPHA:
        const endpoint = 'https://gw.diseasemgmt.octomed.vn/';
        const awsconfig = amplifyconfig;
        const socketEndpoint = 'https://sio.octomed.vn';
        const sentryEnpoint = '';
        const appSyncEndPoint = '';

        return EnvApp(
          endpoint: endpoint,
          awsConfig: awsconfig,
          socketEndpoint: socketEndpoint,
          sentryEnpoint: sentryEnpoint,
          appSyncEndpoint: appSyncEndPoint,
        );
      case ENV.DELTA:
        const endpoint = '';
        const awsconfig = amplifyconfig;
        const socketEndpoint = '';
        const sentryEnpoint = '';
        const appSyncEndPoint = '';

        return EnvApp(
          endpoint: endpoint,
          awsConfig: awsconfig,
          socketEndpoint: socketEndpoint,
          sentryEnpoint: sentryEnpoint,
          appSyncEndpoint: appSyncEndPoint,
        );
      case ENV.STAGING:
        const endpoint = '';
        const awsconfig = amplifyconfig;
        const socketEndpoint = '';
        const sentryEnpoint = '';
        const appSyncEndPoint = '';

        return EnvApp(
          endpoint: endpoint,
          awsConfig: awsconfig,
          socketEndpoint: socketEndpoint,
          sentryEnpoint: sentryEnpoint,
          appSyncEndpoint: appSyncEndPoint,
        );
      case ENV.CUSTOMER:
        const endpoint = '';
        const awsconfig = amplifyconfig;
        const socketEndpoint = '';
        const sentryEnpoint = '';
        const appSyncEndPoint = '';

        return EnvApp(
          endpoint: endpoint,
          awsConfig: awsconfig,
          socketEndpoint: socketEndpoint,
          sentryEnpoint: sentryEnpoint,
          appSyncEndpoint: appSyncEndPoint,
        );
    }
  }
}
