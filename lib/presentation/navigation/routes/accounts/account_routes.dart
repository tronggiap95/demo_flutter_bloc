import 'package:flutter/material.dart';
import 'package:octo360/presentation/navigation/providers/accounts/account_provider.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';

Route<dynamic>? getAccountRoutes(
  RouteSettings routeSettings,
) {
  switch (routeSettings.name) {
    case Routes.logInScreenRoute:
      return MaterialPageRoute(
          builder: (_) => loginScreenProvider, settings: routeSettings);
    case Routes.receiveOtpScreenRoute:
      return MaterialPageRoute(
          builder: (_) => receiveOtpScreenProvider, settings: routeSettings);
    case Routes.completeProfileScreenRoute:
      return MaterialPageRoute(
          builder: (_) => completeProfileScreenProvider,
          settings: routeSettings);
    default:
      return null;
  }
}
