import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:opendiary/services/NavigationService.dart';
import 'package:opendiary/services/RemoteConfigManager.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => RemoteConfigManager());
  locator.registerLazySingleton(() => GoogleSignIn());
}