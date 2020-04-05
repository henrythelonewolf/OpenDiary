import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:opendiary/interfaces/providers/INoteProvider.dart';
import 'package:opendiary/interfaces/services/IFileWriterService.dart';
import 'package:opendiary/providers/LocalDatabaseProvider.dart';
import 'package:opendiary/providers/NoteProvider.dart';
import 'package:opendiary/repositories/LocalDatabaseRepository.dart';
import 'package:opendiary/repositories/NoteRepository.dart';
import 'package:opendiary/services/DialogService.dart';
import 'package:opendiary/services/FileWriterService.dart';
import 'package:opendiary/services/NavigationService.dart';
import 'package:opendiary/services/RemoteConfigManager.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => RemoteConfigManager());
  locator.registerLazySingleton(() => LocalDatabaseProvider());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => GoogleSignIn(
    scopes: [
      "email",
      "profile",
      "https://www.googleapis.com/auth/drive", 
      "https://www.googleapis.com/auth/drive.file",
    ]
  ));
  locator.registerFactory(() => LocalDatabaseRepository());
  locator.registerFactory(() => NoteRepository());
  locator.registerFactory<INoteProvider>(() => NoteProvider());
  locator.registerFactory<IFileWriterService>(() => FileWriterService());
}