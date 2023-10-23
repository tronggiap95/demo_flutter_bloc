import 'package:flutter/material.dart';
import 'package:octo360/presentation/navigation/observer/navigation_app_observer.dart';

class RouteObserverManager {
  static List<NavigatorObserver> listRouteObserver = [
    AppNavObserver(),
  ];
}
