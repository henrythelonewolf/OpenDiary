import 'package:flutter/material.dart';
import 'package:opendiary/constants/route_constants.dart';
import 'package:opendiary/manager/DialogManager.dart';
import 'package:opendiary/router.dart';
import 'package:opendiary/services/NavigationService.dart';

import 'locator/service_locator.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, widget) => Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => DialogManager(child: widget)
        ),
      ),
      theme: ThemeData(primarySwatch: Colors.blue),
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouteConstants.landing,
    );
  }
}