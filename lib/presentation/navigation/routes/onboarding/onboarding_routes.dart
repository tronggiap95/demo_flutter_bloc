import 'package:flutter/material.dart';
import 'package:octo360/presentation/navigation/providers/onboarding/onboarding_provider.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';

Route<dynamic>? getOnBoardingRoutes(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case Routes.splashScreenRoute:
      return MaterialPageRoute(
          builder: (_) => splashProvider, settings: routeSettings);
    case Routes.welcomeScreenRoute:
      return MaterialPageRoute(
          builder: (_) => welcomeProvider, settings: routeSettings);
    default:
      return null;
  }
}
