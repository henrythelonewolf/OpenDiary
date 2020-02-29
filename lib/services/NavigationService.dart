import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  Future<dynamic> navigateTo(String routeName, {Object arguments}) {
    return arguments == null ? navigatorKey.currentState.pushNamed(routeName) : navigatorKey.currentState.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateAndReplace(String routeName) {
    return navigatorKey.currentState.pushReplacementNamed(routeName);
  }

  goBack() {
    return navigatorKey.currentState.pop();
  }
}