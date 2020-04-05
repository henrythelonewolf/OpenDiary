import 'dart:io';

import 'package:logging/logging.dart';
import 'package:opendiary/constants/error_constants.dart';
import 'package:opendiary/dto/ErrorDetailsDto.dart';
import 'package:opendiary/dto/notes/CreateNoteRequestDto.dart';
import 'package:opendiary/interfaces/providers/INoteProvider.dart';
import 'package:opendiary/interfaces/services/IFileWriterService.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class NoteProvider implements INoteProvider {
  final _logger = Logger('NoteRepository');
  final _fileService = locator<IFileWriterService>();

  Future<CreateNoteResponseDto> createNote(CreateNoteRequestDto request) async {
    try {
      // get path
      var docDir = await getApplicationDocumentsDirectory();
      var targetDir = Directory('${docDir.path}/note/');
      var targetDirExists = await targetDir.exists();
      if (targetDirExists == false) {
        await targetDir.create(recursive: true);
      }

      var uuid = Uuid();
      var fileName = uuid.v1() + '.txt';
      var file = File('${targetDir.path}/$fileName');
      file  = await _fileService.writeToFile(file, content: request.content, title: request.title);
      file = await file.create();

      return CreateNoteResponseDto(filename: fileName, localPath: file.path);
    } on FileSystemException catch (fsError, stack) {
      _logger.severe(fsError.toString());
      _logger.severe(stack.toString());

      return CreateNoteResponseDto(error: ErrorDetailsDto(errorCode: ErrorCode.FileCreationFailure));
    } on Exception catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());

      return CreateNoteResponseDto(error: ErrorDetailsDto(errorCode: ErrorCode.GeneralException));
    }
  }
}