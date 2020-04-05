import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:opendiary/app.dart';
import 'package:opendiary/locator/service_locator.dart';

void logWrapped(String text, Level logLevel) {
  final pattern = RegExp('.{1,128}'); // 128 is the size of each chunk
  pattern.allMatches(text).forEach((match) => log(colorize(match.group(0), logLevel)));
}

String colorize(String message, Level logLevel) {
  if (logLevel == Level.SEVERE) {
    return '\u001b[1;31m' + message;
  } else {
    return message;
  }
}

final routeObserver = RouteObserver<PageRoute>();

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((data) {
    var message = '${data.loggerName} | ${data.level} | ${data.time.toString()} | ${data.message}';
    logWrapped(message, data.level);
  });
  setupLocator();
  runApp(App());
}
