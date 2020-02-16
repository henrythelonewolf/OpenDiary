import 'package:flutter/material.dart';
import 'package:opendiary/pages/Landing.dart';

import 'constants/route_constants.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.landing:
        return MaterialPageRoute(builder: (_) => Landing());
      default:
        return MaterialPageRoute(builder: (_) => Landing());
    }
  }
}