import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:opendiary/globals.dart' as globals;
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/models/Database.dart';
import 'package:opendiary/repositories/LocalDatabaseRepository.dart';
import 'package:opendiary/services/NavigationService.dart';
import 'package:rxdart/subjects.dart';

class HomepageBloc {
  LocalDatabaseRepository _localDatabaseRepository = locator<LocalDatabaseRepository>();
  NavigationService navigationService = locator<NavigationService>();

  final PublishSubject<List<Diary>> _records = PublishSubject();
  Stream<List<Diary>> get records => _records.stream;

  HomepageBloc() {
    initializeData();
  }

  Future<void> initializeData() async {
    globals.remoteConfigInstance = await RemoteConfig.instance;
    var records = await _localDatabaseRepository.getDiaries();
    _records.sink.add(records);
  }

  handleButtonTap() {
    globals.remoteConfigInstance.fetch(expiration: const Duration(seconds: 0));
    globals.remoteConfigInstance.activateFetched();
    var clientId = globals.remoteConfigInstance.getString("clientId");
    var clientSecret = globals.remoteConfigInstance.getString("clientSecret");
    print("clientId: $clientId");
    print("clientSecret: $clientSecret");
  }

  void dispose() {
    _records.close();
  }
}