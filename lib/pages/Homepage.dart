import 'package:flutter/material.dart';
import 'package:opendiary/bloc/HomepageBloc.dart';
import 'package:opendiary/bloc/LoginBloc.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  HomepageBloc _bloc = HomepageBloc();
  LoginBloc _loginBloc = LoginBloc();

  @override initState() {
    super.initState();
    _loginBloc.doAutoSignIn();
  }

  Widget _buildDrawer() => Drawer(
    child: ListView(children: <Widget>[
      SizedBox(
        height: 100,
        child: DrawerHeader(
          child: Text(_loginBloc.getEmail(),
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
      ),
      ListTile(
        title: Text("Sign Out"),
        onTap: () => _loginBloc.handleGoogleSignOut(),
      ),
    ],),
  );

  Widget _buildAppBar() => AppBar(
    title: Text("OpenDiary")
  );

  Widget _buildStreamBody() => StreamBuilder(
    stream: _bloc.records,
    builder: (context, snap) => snap.hasData == true ? _buildListView() : Container(),
  );

  Widget _buildListView() => Container(
    child: Text("this is a proper view with data"),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildStreamBody(),
      floatingActionButton: FloatingActionButton(onPressed: () => _bloc.handleButtonTap(),
      child: Icon(Icons.add),)
    );
  }
}