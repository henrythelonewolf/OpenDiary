import 'package:flutter/material.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/services/DialogService.dart';
import 'package:progress_dialog/progress_dialog.dart';

class DialogManager extends StatefulWidget {
  final Widget child;
  DialogManager({Key key, this.child}) : super(key: key);

  _DialogManagerState createState() => _DialogManagerState();
}

class _DialogManagerState extends State<DialogManager> {
  DialogService _dialogService = locator<DialogService>();

  @override void initState() {
    super.initState();
    _dialogService.registerDialogListener(_showDialog, _showProgressDialog);
  }

  @override Widget build(BuildContext context) {
    return widget.child;
  }

  void _showDialog(String content, Function onDismiss) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        content: Text(content),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _dialogService.dialogComplete();
              onDismiss();
              Navigator.of(context).pop();
            },
            child: Text('OK')
          )
        ],
      )
    );
  }

  void _showProgressDialog(bool show) {
    var dialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    dialog.style(progressWidget: Container(
      margin: EdgeInsets.all(10),
      child: CircularProgressIndicator()
    ));

    if (show == true) {
      dialog.show();
    } else {
      dialog.dismiss();
    }
  }
}