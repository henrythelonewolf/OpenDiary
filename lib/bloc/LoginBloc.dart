import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/constants/route_constants.dart';
import 'package:opendiary/services/NavigationService.dart';

class LoginBloc {
  GoogleSignIn _googleSignIn = locator<GoogleSignIn>();
  NavigationService _navigationService = locator<NavigationService>();
  
  Future<void> doAutoSignIn({bool navigateToHome = false}) async {
    var acc = await _googleSignIn.signInSilently();
    if (acc != null && navigateToHome == true) {
      _navigationService.navigateAndReplace(RouteConstants.home);
    }
    log("Login succesfully as ${acc?.email}");
  }

  Future<void> handleGoogleSignIn() async {
    var account = await _googleSignIn.signIn();
    var authentication = await account.authentication;
    log("access token: ${authentication.accessToken}");
    log("id token: ${authentication.idToken}");
    _navigationService.navigateAndReplace(RouteConstants.home);
  }

  Future<void> handleGoogleSignOut() async {
    await _googleSignIn.disconnect();
    _navigationService.navigateAndReplace(RouteConstants.landing);
  }

  String getEmail() {
    return _googleSignIn.currentUser == null ? "" : _googleSignIn.currentUser.email;
  }
}