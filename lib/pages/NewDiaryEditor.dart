import 'package:flutter/material.dart';
import 'package:opendiary/bloc/EditorBloc.dart';

class NewDiaryEditor extends StatefulWidget {
  @override
  _NewDiaryEditorState createState() => _NewDiaryEditorState();
}

class _NewDiaryEditorState extends State<NewDiaryEditor> {
  Widget _buildAppBar() => AppBar();
  final EditorBloc _bloc = EditorBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              onChanged: _bloc.updateTitle,
              style: TextStyle(fontSize: 18),
              maxLines: 1,
              decoration:
                  InputDecoration(hintText: 'Title', border: InputBorder.none),
              autofocus: true,
            ),
            TextField(
              onChanged: _bloc.updateContent,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Contents',
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            )
          ],
        ),
      ),
    );
  }
}
