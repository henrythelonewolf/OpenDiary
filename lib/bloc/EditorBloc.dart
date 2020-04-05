import 'package:logging/logging.dart';
import 'package:opendiary/constants/error_constants.dart';
import 'package:opendiary/dto/notes/CreateNoteRequestDto.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/models/Database.dart';
import 'package:opendiary/repositories/LocalDatabaseRepository.dart';
import 'package:opendiary/repositories/NoteRepository.dart';
import 'package:rxdart/subjects.dart';

class EditorBloc {
  // util class
  final _logger = Logger('EditorBloc');
  final _noteRepository = locator<NoteRepository>();
  final _localRepository = locator<LocalDatabaseRepository>();
  
  // diary controllers
  final _titleController = BehaviorSubject<String>();
  final _contentsController = BehaviorSubject<String>();

  // ui controllers
  final _loadingController = PublishSubject<bool>();
  final _errorController = BehaviorSubject<String>();
  
  // streams
  Stream<String> get title => _titleController.stream;
  Stream<String> get contents => _contentsController.stream;

  // ui streams
  Stream<bool> get isLoading => _loadingController.stream;
  Stream<String> get error => _errorController.stream;

  void updateTitle(String event) {
    _titleController.sink.add(event);
  }

  void updateContent(String event) {
    _contentsController.sink.add(event);
  }

  Future<void> triggerSaveDiary() async {
    try {
      _loadingController.sink.add(true);
      // construct request dto
      var createNoteRequest = CreateNoteRequestDto()
      ..title = _titleController.value ?? ''
      ..content = _contentsController.value ?? '';

      // create note locally
      var createNoteResponse = await _noteRepository.createNote(createNoteRequest);
      if (createNoteResponse.error != null) {
        var errorMessage = '${createNoteResponse.error.errorMessage ?? createNoteResponse.error.autoErrorMessage} error code: ${createNoteResponse.error.errorCode}';
        _loadingController.sink.add(false);
        _errorController.sink.add(errorMessage);
      }

      // create note record
      var createDateTime = DateTime.now().toUtc().toIso8601String();
      var model = Diary()
      ..title = createNoteRequest.title
      ..filename = createNoteResponse.filename
      ..createdDateTime = createDateTime
      ..updatedDateTime = createDateTime;

      var createDiaryResponse = await _localRepository.createDiary(model, createNoteResponse.localPath);
      if (createDiaryResponse.error != null) {
        var errorMessage = '${createDiaryResponse.error.errorMessage ?? createDiaryResponse.error.autoErrorMessage} error code: ${createDiaryResponse.error.errorCode}';
        _loadingController.sink.add(false);
        _errorController.sink.add(errorMessage);
      }

      _loadingController.sink.add(false);
      _errorController.sink.add('SaveSuccess');
    } on Exception catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());

      var errorMessage = '${ErrorMessage.getErrorMessage(ErrorCode.GeneralException)} error code: ${ErrorCode.GeneralException}';
      _loadingController.sink.add(false);
      _errorController.sink.add(errorMessage);
    }
  }

  dispose() {
    _titleController.close();
    _contentsController.close();
    _loadingController.close();
    _errorController.close();
  }
}