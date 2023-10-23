import 'dart:io';

import 'package:octo360/data/di/di.dart';
import 'package:octo360/data/local/bridge/package/package_manager_plugin.dart';
import 'package:octo360/data/local/share_pref/shared_pref.dart';
import 'package:octo360/data/repository/auth/authen_repo.dart';
import 'package:octo360/l10n/locale_enum.dart';

enum GraphQLHeaderType { guest, audit, medication, defaultHeader, message }

enum HeaderAppName {
  octo360Android('octo360-android'),
  octo360iOS('octo360-health-ios');

  final String value;

  const HeaderAppName(this.value);

  static String byPlatfrom() {
    return Platform.isAndroid
        ? HeaderAppName.octo360Android.value
        : HeaderAppName.octo360iOS.value;
  }
}

class GraphQLHeader {
  static Future<Map<String, String>> getHeaders({
    GraphQLHeaderType type = GraphQLHeaderType.defaultHeader,
  }) async {
    Map<String, String> headers = {};
    //APIs need to have the app name and app version
    //In order to enable the firewall security
    final defaultversion = await PackageManagerPlugin.getAppVersion();
    final defaultName = HeaderAppName.byPlatfrom();

    switch (type) {
      case GraphQLHeaderType.guest:
        headers = {
          'apollographql-client-name': defaultName,
          'apollographql-client-version': defaultversion,
        };
        break;
      case GraphQLHeaderType.audit:
        final authRepo = instance<AuthenRepo>();
        final token = await authRepo.getUserToken();
        headers = {
          'apollographql-client-name': defaultName,
          'apollographql-client-version': defaultversion,
          'access-token': token,
        };
        break;
      case GraphQLHeaderType.defaultHeader:
        //Get authen token
        final authRepo = instance<AuthenRepo>();
        final token = await authRepo.getUserToken();
        final locale = await SharedPref.getCurrentLocale();

        headers = {
          'access-token': token,
          'apollographql-client-name': defaultName,
          'apollographql-client-version': defaultversion,
          'accept-language': locale ?? LocaleEnum.vi.name,
        };
        break;
      default:
        break;
    }
    return headers;
  }
}
