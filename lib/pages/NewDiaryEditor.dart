import 'package:flutter/material.dart';
import 'package:opendiary/bloc/EditorBloc.dart';
import 'package:opendiary/constants/route_constants.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/services/DialogService.dart';
import 'package:opendiary/services/NavigationService.dart';

class NewDiaryEditor extends StatefulWidget {
  @override
  _NewDiaryEditorState createState() => _NewDiaryEditorState();
}

class _NewDiaryEditorState extends State<NewDiaryEditor> {
  final _editBloc = EditorBloc();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  @override initState() {
    super.initState();
    _editBloc.isLoading.listen((status) => _dialogService.showProgressDialog(status));
    _editBloc.error.listen((data) => data == 'SaveSuccess' ? onSaveSuccess() : onError(data));
  }

  @override dispose() {
    _editBloc.dispose();
    super.dispose();
  }

  void onSaveSuccess() {
    _navigationService.goBack();
  }

  void onError(String data) {
    _dialogService.showDialog(content: data);
  }

  Widget _buildAppBar() => AppBar(
    actions: <Widget>[
      IconButton(
        onPressed: () => _editBloc.triggerSaveDiary(),
        icon: Icon(Icons.check)
      ),
    ],
  );
  
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
              onChanged: _editBloc.updateTitle,
              style: TextStyle(fontSize: 18),
              maxLines: 1,
              decoration:
                  InputDecoration(hintText: 'Title', border: InputBorder.none),
              autofocus: true,
            ),
            TextField(
              onChanged: _editBloc.updateContent,
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
