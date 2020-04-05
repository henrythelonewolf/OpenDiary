import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:opendiary/bloc/HomepageBloc.dart';
import 'package:opendiary/bloc/LoginBloc.dart';
import 'package:opendiary/constants/route_constants.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/main.dart';
import 'package:opendiary/services/NavigationService.dart';
import 'package:opendiary/viewmodels/DiaryViewModel.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with RouteAware {
  final _navigationService = locator<NavigationService>();
  final _logger = Logger('Homepage');
  HomepageBloc _homepageBloc = HomepageBloc();
  LoginBloc _loginBloc = LoginBloc();

  @override void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override dispose() {
    _homepageBloc.dispose();
    _loginBloc.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override initState() {
    super.initState();
    _loginBloc.error.listen((data) => data == 'Success' ? onLogoutSuccess() : onLoginBlocError(data));
    _loginBloc.doAutoSignIn();
  }

  void didPopNext() {
    _logger.info('Popped detected. Refreshing listview.');
    _homepageBloc.fetchDiaries();
  }

  void onLogoutSuccess() {
    _navigationService.navigateAndReplace(RouteConstants.landing);
  }

  void onLoginBlocError(String errorMessage) {

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

  Widget _buildListView(List<DiaryViewModel> diaries) => RefreshIndicator(
    onRefresh: () => _homepageBloc.fetchDiaries(isHardRefresh: true),
    child: Container(
      child: diaries.length == 0 
        ? SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(), 
            child: Container(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top, 
              child: Center(
                child: Text('No Records.'),
              )
            )
          )
        : ListView(
          children: diaries.map((diary) => ListTile(
            onTap: () => {},
            title: Text(diary?.title), subtitle: Text(diary?.createdDateTime),
          )).toList(),
        ),
    )
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _homepageBloc.records,
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