import 'package:opendiary/dto/ErrorDetailsDto.dart';

class CreateNoteRequestDto {
  String title;
  String content;
}

class CreateNoteResponseDto {
  String filename;
  String localPath;
  ErrorDetailsDto error;
  CreateNoteResponseDto({this.filename, this.localPath, this.error});
}