import 'package:opendiary/dto/database/CreateNewDiaryDto.dart';
import 'package:opendiary/dto/home/GetDiaryDto.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/models/Database.dart';
import 'package:opendiary/providers/LocalDatabaseProvider.dart';

class LocalDatabaseRepository {
  final LocalDatabaseProvider _localDatabaseProvider = locator<LocalDatabaseProvider>();
  Future<void> initializeDatabase() => _localDatabaseProvider.initializeDatabase();
  Future<GetDiaryResponseDto> getDiaries(bool isHardRefresh) => _localDatabaseProvider.getDiaries(isHardRefresh: isHardRefresh);
  Future<CreateNewDiaryResponseDto> createDiary(Diary diary, String path) => _localDatabaseProvider.addDiary(diary, path);
}