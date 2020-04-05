import 'package:opendiary/dto/notes/CreateNoteRequestDto.dart';
import 'package:opendiary/interfaces/providers/INoteProvider.dart';
import 'package:opendiary/locator/service_locator.dart';

class NoteRepository {
  final _noteProvider = locator<INoteProvider>();
  Future<CreateNoteResponseDto> createNote(CreateNoteRequestDto request) => _noteProvider.createNote(request);
}