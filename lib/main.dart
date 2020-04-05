import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:opendiary/app.dart';
import 'package:opendiary/locator/service_locator.dart';

void logWrapped(String text) {
  final pattern = RegExp('.{1,128}'); // 128 is the size of each chunk
  pattern.allMatches(text).forEach((match) => log(match.group(0)));
}

final routeObserver = RouteObserver<PageRoute>();

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((data) {
    var message = '${data.loggerName} | ${data.level} | ${data.time.toString()} | ${data.message}';
    logWrapped(message);
  });
  setupLocator();
  runApp(App());
}
