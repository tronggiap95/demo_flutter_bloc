import 'package:flutter/material.dart';
import 'package:octo360/presentation/navigation/routes/accounts/account_routes.dart';
import 'package:octo360/presentation/navigation/routes/home/home_routes.dart';
import 'package:octo360/presentation/navigation/routes/onboarding/onboarding_routes.dart';
import 'package:octo360/presentation/navigation/routes/profile/profile_routes.dart';
import 'package:octo360/presentation/screens/launch/splash_screen.dart';

class NavigationApp {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> getRoutes(RouteSettings routeSettings) {
    final onBoardingRoutes = getOnBoardingRoutes(routeSettings);
    if (onBoardingRoutes != null) {
      return onBoardingRoutes;
    }

    final accountRoutes = getAccountRoutes(routeSettings);
    if (accountRoutes != null) {
      return accountRoutes;
    }

    final homeRoutes = getHomeRoutes(routeSettings);
    if (homeRoutes != null) {
      return homeRoutes;
    }

    final profileRoutes = getProfileRoutes(routeSettings);
    if (profileRoutes != null) {
      return profileRoutes;
    }

    return MaterialPageRoute(
        builder: (_) => const SplashScreen(), settings: routeSettings);
  }

  static Future<T?> routeTo<T extends Object?>(
      BuildContext context, String name,
      {Object? agrs}) {
    return Navigator.of(context).pushNamed(name, arguments: agrs);
  }

  static Future<T?> replaceWith<T extends Object?>(
      BuildContext context, String name,
      {Object? agrs}) {
    return Navigator.of(context).pushReplacementNamed(name, arguments: agrs);
  }

  static Future<bool> back<T extends Object>(BuildContext context,
      [T? result]) {
    return Navigator.of(context).maybePop(result);
  }

  /// route to screen and remove all the routes from navigator
  static Future<T?> popAllAndRouteTo<T extends Object?>(
      BuildContext context, String name,
      {Object? agrs}) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
        name, (Route<dynamic> route) => false,
        arguments: agrs);
  }

  /*
  * pop will ignore the "WillPopScope" widget and force to go back to previous page
  * Using for a dialog sets "willPopScope = false"
  */
  static void pop<T extends Object>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }

  static void popUntil<T extends Object>(BuildContext context, String name,
      [T? result]) {
    Navigator.of(context).popUntil(ModalRoute.withName(name));
  }

  static void popDialog<T extends Object>(BuildContext context, [T? result]) {
    Navigator.of(context, rootNavigator: true).pop(result);
  }
}
