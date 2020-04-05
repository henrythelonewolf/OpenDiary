import 'package:flutter/material.dart';
import 'package:opendiary/pages/Homepage.dart';
import 'package:opendiary/pages/LoginPage.dart';
import 'package:opendiary/pages/NewDiaryEditor.dart';

import 'constants/route_constants.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.landing:
        return MaterialPageRoute(settings: settings, builder: (_) => LoginPage());
      case RouteConstants.home:
        return MaterialPageRoute(settings: settings, builder: (_) => Homepage());
      case RouteConstants.adddiary:
        return MaterialPageRoute(settings: settings, builder: (_) => NewDiaryEditor());
      default:
        return MaterialPageRoute(settings: settings, builder: (_) => Homepage());
    }
  }
}