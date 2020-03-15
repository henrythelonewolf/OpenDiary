import 'package:opendiary/models/Diary.dart';
import 'package:rxdart/subjects.dart';

class EditorBloc {
  // model state
  Diary _model = Diary();
  
  // controllers
  final _titleController = BehaviorSubject<String>();
  final _contentsController = BehaviorSubject<String>();
  
  // streams
  Stream<String> get title => _titleController.stream;
  Stream<String> get contents => _contentsController.stream;

  void updateTitle(String event) {
    _model.title = event;
    _titleController.sink.add(event);
  }

  void updateContent(String event) {
    _model.contents = event;
    _contentsController.sink.add(event);
  }

  dispose() {
    _titleController.close();
    _contentsController.close();
  }
}