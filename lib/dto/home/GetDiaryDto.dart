import 'package:opendiary/dto/ErrorDetailsDto.dart';
import 'package:opendiary/models/Database.dart';

class GetDiaryResponseDto {
  List<Diary> diaries;
  ErrorDetailsDto error;
  GetDiaryResponseDto({this.diaries, this.error});
} 