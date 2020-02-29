import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:opendiary/bloc/LoginBloc.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState(); 
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc _bloc = LoginBloc();

  @override initState() {
    super.initState();
    _bloc.doAutoSignIn(navigateToHome: true);
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
            GoogleSignInButton(onPressed: () => _bloc.handleGoogleSignIn()),
          ],
        ),
      ),
    );
  }
}