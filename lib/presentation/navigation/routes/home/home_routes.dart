import 'package:flutter/material.dart';
import 'package:octo360/presentation/navigation/providers/home/home_provider.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';
import 'package:octo360/presentation/screens/home/home.dart';
import 'package:octo360/presentation/screens/home/octobeat/octobeat_troubleshooting_screen.dart';

Route<dynamic>? getHomeRoutes(
  RouteSettings routeSettings,
) {
  switch (routeSettings.name) {
    case Routes.octoBeatDeviceViewRoute:
      return MaterialPageRoute(
        builder: (_) => octoBeatDeviceProvider(),
        settings: routeSettings,
      );
    case Routes.homeRoute:
      return MaterialPageRoute(
          builder: (_) => const MyWidget(), settings: routeSettings);
    case Routes.octoBeatTroubleshootingRoute:
      return MaterialPageRoute(
          builder: (_) => const OctobeatTroubleshootingScreen(),
          settings: routeSettings);
    default:
      return null;
  }
}
