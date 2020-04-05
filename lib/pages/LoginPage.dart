import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:opendiary/bloc/LoginBloc.dart';
import 'package:opendiary/constants/route_constants.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/services/NavigationService.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState(); 
}

class _LoginPageState extends State<LoginPage> {
  final _navigationService = locator<NavigationService>();
  final _loginBloc = LoginBloc();

  @override initState() {
    super.initState();
    _loginBloc.error.listen((data) => data == 'Success' ? onLoginSuccess() : onError(data));
    _loginBloc.doAutoSignIn(navigateToHome: true);
  } 

  void onLoginSuccess() {
    _navigationService.navigateAndReplace(RouteConstants.home);
  }

  void onError(String errorMessage) {

  }

  _buildAppLogo() => Text("OpenDiary", 
  style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  ),);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildAppLogo(),
            Container(height: 70,),
            GoogleSignInButton(onPressed: () => _loginBloc.handleGoogleSignIn()),
          ],
        ),
      ),
    );
  }
}