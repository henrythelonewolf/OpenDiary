import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:intl/intl.dart';
import 'package:opendiary/globals.dart' as globals;
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/models/Database.dart';
import 'package:opendiary/repositories/LocalDatabaseRepository.dart';
import 'package:opendiary/services/NavigationService.dart';
import 'package:opendiary/viewmodels/DiaryViewModel.dart';
import 'package:rxdart/subjects.dart';

class HomepageBloc {
  LocalDatabaseRepository _localDatabaseRepository = locator<LocalDatabaseRepository>();
  NavigationService navigationService = locator<NavigationService>();

  final BehaviorSubject<List<DiaryViewModel>> _records = BehaviorSubject();
  Stream<List<DiaryViewModel>> get records => _records.stream;
  final format = DateFormat('yyyy-MM-dd hh:mm:ss aa');

  HomepageBloc() {
    initializeData();
  }

  Future<void> initializeData() async {
    globals.remoteConfigInstance = await RemoteConfig.instance;
    await fetchDiaries();
  }

  Future<void> fetchDiaries({isHardRefresh = false}) async {
    var response = await _localDatabaseRepository.getDiaries(isHardRefresh);
    if (response.error != null) {
      // todo: errorhandling
    }
    var records = response.diaries;
    var viewModels = records.map((r) => _constructViewModels(r)).toList();
    _records.sink.add(viewModels);
  }

  String _formatDisplayDateTime(String dateTime) {
    return format.format(DateTime.tryParse(dateTime)?.toLocal() ?? DateTime.fromMicrosecondsSinceEpoch(0));
  }

  DiaryViewModel _constructViewModels(Diary r) => DiaryViewModel(title: r.title, createdDateTime: _formatDisplayDateTime(r.createdDateTime), updatedDateTime: _formatDisplayDateTime(r.createdDateTime));

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