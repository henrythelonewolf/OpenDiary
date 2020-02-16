import 'package:flutter/material.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState(); 
}

class _LandingState extends State<Landing> {
  Widget _buildAppBar() => AppBar(
    title: Text("OpenDiary"),
  );
  
  Widget _buildLandingBody() => Container();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildLandingBody(),
    );
  }
}