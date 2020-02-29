import 'dart:async';
import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/services/NavigationService.dart';
import 'package:rxdart/subjects.dart';

import 'package:opendiary/globals.dart' as globals;

class HomepageBloc {
  GoogleSignIn _googleSignIn = locator<GoogleSignIn>();
  NavigationService navigationService = locator<NavigationService>();

  final PublishSubject<List<String>> _records = PublishSubject();
  Stream<List<String>> get records => _records.stream;
  
  HomepageBloc() {
    // init and forget
    initializeData();
  }

  Future<void> initializeData() async {
    globals.remoteConfigInstance = await RemoteConfig.instance;
    if (_googleSignIn.currentUser == null) {
      log("Severe error - user is not logged in");
      return;
    }
    
    _records.sink.add(["sample data"]);
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