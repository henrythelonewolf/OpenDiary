import 'dart:async';

class DialogService {
  Function _showDialogListener;
  Function _showProgressDialogListener;
  Completer _dialogCompleter;

  bool get isDeployed => _dialogCompleter != null;

  void registerDialogListener(Function showDialogListener, Function showProgressDialogListener) {
    _showDialogListener = showDialogListener;
    _showProgressDialogListener = showProgressDialogListener;
  }

  Future showDialog({String content, Function onDismiss}) {
    _dialogCompleter = Completer();
    _showDialogListener(content, onDismiss ?? () => {});
    return _dialogCompleter.future;
  }

  void showProgressDialog(bool show) {
    _showProgressDialogListener(show);
  }

  void dialogComplete() {
    if (_dialogCompleter == null) {
      return;
    }

    _dialogCompleter.complete();
    _dialogCompleter = null;
  }
}