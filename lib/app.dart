import 'package:flutter/material.dart';
import 'package:opendiary/constants/route_constants.dart';
import 'package:opendiary/router.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouteConstants.landing,
    );
  }
}