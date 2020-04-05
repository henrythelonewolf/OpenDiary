import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/constants/route_constants.dart';
import 'package:opendiary/services/NavigationService.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc {
  final _logger = Logger('LoginBloc');
  GoogleSignIn _googleSignIn = locator<GoogleSignIn>();

  // ui controllers
  final _errorController = BehaviorSubject<String>();
  // ui streams
  Stream<String> get error => _errorController.stream;
  
  Future<void> doAutoSignIn({bool navigateToHome = false}) async {
    var acc = await _googleSignIn.signInSilently();
    if (acc != null && navigateToHome == true) {
      _errorController.sink.add('Success');
      _logger.info("Login succesfully as ${acc?.email}");
    }
  }

  Future<void> handleGoogleSignIn() async {
    var account = await _googleSignIn.signIn();
    var authentication = await account.authentication;
    _logger.info("access token: ${authentication.accessToken}");
    _logger.info("id token: ${authentication.idToken}");
    _errorController.sink.add('Success');
  }

  Future<void> handleGoogleSignOut() async {
    await _googleSignIn.disconnect();
    _errorController.sink.add('Success');
  }

  String getEmail() {
    return _googleSignIn.currentUser == null ? "" : _googleSignIn.currentUser.email;
  }

  void dispose() {
    _errorController.close();
  }
}