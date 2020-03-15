import 'package:flutter/material.dart';
import 'package:opendiary/bloc/HomepageBloc.dart';
import 'package:opendiary/bloc/LoginBloc.dart';
import 'package:opendiary/constants/route_constants.dart';
import 'package:opendiary/models/Database.dart';

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

  Widget _buildListView(List<Diary> diaries) => Container(
    child: diaries.length == 0 
      ? Center( child: Text('No Records.'),)
      : ListView(
        children: diaries.map((diary) => ListTile(
          onTap: () => {},
          title: Text(diary?.title), subtitle: Text(diary?.createdDateTime),
        )).toList(),
      ),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bloc.records,
      builder: (context, snap) => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Scaffold(
            appBar: _buildAppBar(),
            drawer: _buildDrawer(),
            body: snap.hasData == false ? Container() : _buildListView(snap.data),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, RouteConstants.adddiary),
              child: Icon(Icons.add),
            )
          ),
          snap.hasData == false ? CircularProgressIndicator() : Container(),
        ],
      )
    );
  }
}