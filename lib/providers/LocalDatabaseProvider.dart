import 'dart:convert';
import 'dart:io' as IO;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:logging/logging.dart';
import 'package:opendiary/clients/GoogleHttpClient.dart';
import 'package:opendiary/constants/error_constants.dart';
import 'package:opendiary/dto/ErrorDetailsDto.dart';
import 'package:opendiary/dto/database/CreateNewDiaryDto.dart';
import 'package:opendiary/dto/home/GetDiaryDto.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/models/Database.dart';

class LocalDatabaseProvider {
  final _logger = Logger('LocalDatabaseProvider');
  GoogleSignIn _googleSignIn = locator<GoogleSignIn>();
  OpenDiaryDatabase database;
  DriveApi drive;

  Future<bool> _initializeDriveApi() async {
    _logger.info('initializeDriveApi invoked.');
    try {
      if (_googleSignIn.currentUser == null) {
        _logger.severe("error - user is not logged in");
        return false;
      }
      var headers = await _googleSignIn.currentUser.authHeaders;
      var googleHttpClient = GoogleHttpClient(headers);
      drive = DriveApi(googleHttpClient);
      
      _logger.info('initialized driveApi successfully. returning.');
      return true;
    } on Exception catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());

      return false;
    }
  }

  Future<File> _fetchOpenDiaryDirectory() async {
    _logger.info('fetchDiaryDirectory invoked.');
    try {
      var query = """
        parents in 'root' 
        and mimeType = 'application/vnd.google-apps.folder'
        and name = 'opendiary'
      """;
      var queryResults = await drive.files.list(q: query);
      var fileList = queryResults?.files;
      var appFolder = fileList == null || fileList.length == 0 ? null : fileList.first;
      if (appFolder == null) {
        var folder = File();
        folder.name = 'opendiary';
        folder.parents = ['root'];
        folder.mimeType = 'application/vnd.google-apps.folder';
        appFolder = await drive.files.create(folder);
      }
      _logger.info('fetched opendiary directory successfully. returning.');
      return appFolder;
    } on ApiRequestError catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());

      return null;
    }
  }

  Future<File> _fetchDiaryDirectory(String openDiaryDirId) async {
    _logger.info('fetchDiaryDirectory invoked.');
    try {
      var query = """
        parents in '$openDiaryDirId'
        and mimeType = 'application/vnd.google-apps.folder'
        and name = 'diary'
      """;
      var queryResults = await drive.files.list(q: query);
      var fileList = queryResults?.files;
      var diaryDirectory = fileList == null || fileList.length == 0 ? null : fileList.first;
      if (diaryDirectory == null) {
        var folder = File()
        ..name = 'diary'
        ..parents = ['$openDiaryDirId']
        ..mimeType = 'application/vnd.google-apps.folder';
        diaryDirectory = await drive.files.create(folder);
      }

      _logger.info('fetched diary directory successfully. returning.');
      return diaryDirectory;
    } on ApiRequestError catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());

      return null; 
    }
  }

  Future<bool> _updateDatabase({String openDiaryDirId}) async {
    _logger.info('updateDatabase invoked.');
    try {
      if (openDiaryDirId == null) {
        var appFolder = await _fetchOpenDiaryDirectory();
        openDiaryDirId = appFolder.id;
      }

      var query = """
        parents in '$openDiaryDirId'
        and name = 'database.json'
      """;
      var queryResults = await drive.files.list(q: query);
      var fileList = queryResults?.files;
      var database = fileList == null || fileList.length == 0 ? null : fileList.first;
      if (database == null) {
        _logger.info('database not found. update failed. returning.');
        return false;
      }

      _logger.info('database object found in drive proceeding /w update procedure.');
      var contents = this.database.toJson();
      var bytes = utf8.encode(contents);
      var byteStream = Stream.fromIterable([bytes]);
      var newDatabase = File()
      ..name = database.name
      ..mimeType = database.mimeType;
      _logger.info('beginning to update database.');
      await drive.files.update(newDatabase, database.id, uploadMedia: Media(byteStream, bytes.length));
      _logger.info('update finished successfully. returning.');
      return true;
    } on ApiRequestError catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());
      
      throw error;
    } on Exception catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());
      
      return false;
    }
  }
  
  Future<File> _writeFileToDrive(String filename, String localPath, String driveParentDir, {String mimeType = ''}) async {
    try {
      _logger.info('writeFileToDrive invoked. filename: $filename, localPath: $localPath, driveParentDir: $driveParentDir');
      var file = IO.File(localPath);
      var media = Media(file.openRead(), file.lengthSync());
      var metadata = File()
      ..name = filename
      ..mimeType = mimeType
      ..parents = [driveParentDir];

      var uploaded = await drive.files.create(metadata, uploadMedia: media);
      _logger.info('uploaded file. fileId: ${uploaded.id}. returning.');
      return uploaded;
    } on ApiRequestError catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());

      throw error;
    } on Exception catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());
      return null;
    }
  }

  Future<void> _removeRemoteFile(String fileId) async {
    try {
      _logger.info('removing remoteFile with if $fileId');
      await drive.files.delete(fileId);
      _logger.info('remoteFile removed.');
    } on Exception catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());
    }
  }
  
  Future<ErrorDetailsDto> initializeDatabase() async {
    try {  
      var isSuccess;
      
      if (drive == null) {
        isSuccess = await _initializeDriveApi();
      }

      if (isSuccess == false) {
        return ErrorDetailsDto(errorCode: ErrorCode.DriveAPIInitializaitonFailure);
      }

      var appFolder = await _fetchOpenDiaryDirectory();
      if (appFolder == null) {
        return ErrorDetailsDto(errorCode: ErrorCode.NotFound);
      }

      var appFolderId = appFolder.id;

      var query = """
        parents in '$appFolderId'
        and name = 'database.json'
      """;
      var queryResults = await drive.files.list(q: query);
      var fileList = queryResults?.files;
      var database = fileList == null || fileList.length == 0 ? null : fileList.first;
      if (database == null) {
        var metadata = File()
        ..name = 'database.json'
        ..parents = [appFolderId]
        ..mimeType = 'application/json';

        var databaseObj = OpenDiaryDatabase()
        ..diary = <Diary>[];

        var contents = databaseObj.toJson();
        var bytes = utf8.encode(contents);
        var byteStream = Stream.fromIterable([bytes]);
        database = await drive.files.create(metadata, uploadMedia: Media(byteStream, bytes.length));
      }

      Media databaseObj = await drive.files.get(database.id, downloadOptions: DownloadOptions.FullMedia);
      var remoteContents = await readDatabaseContent(databaseObj);
      this.database = OpenDiaryDatabase.fromJson(remoteContents);
      return null;
    } on ApiRequestError catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());
      
      return ErrorDetailsDto(errorCode: ErrorCode.DriveAPIRequestFailure);
    } on Exception catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());
      
      return ErrorDetailsDto(errorCode: ErrorCode.GeneralException);
    }
  }

  Future<String> readDatabaseContent(Media database) async {
    var buffer = StringBuffer();
    var stream = database.stream.transform(utf8.decoder);
    await for(var part in stream) {
      buffer.write(part);
    }
    var contents = buffer.toString();
    return contents;
  }

  Future<CreateNewDiaryResponseDto> addDiary(Diary diary, String path) async {
    try {
      _logger.info('addDiary invoked. Saving ${diary?.title} with path: $path');
      if (diary == null) {
        return null;
      }
      database.diary.add(diary);

      var openDiaryDir = await _fetchOpenDiaryDirectory();
      var diaryDir = await _fetchDiaryDirectory(openDiaryDir.id);
      if (diaryDir == null) {
        _logger.info('fetchDiaryDirectory returned null. returning.');
        return CreateNewDiaryResponseDto(error: ErrorDetailsDto(errorCode: ErrorCode.NotFound, errorMessage: 'opendiary/diary directory not found in user drive.'));
      }

      var remoteDiary = await _writeFileToDrive(diary.filename, path, diaryDir.id, mimeType: 'text/plain');
      if (remoteDiary == null) {
        _logger.info('writeFileToDrive failed. returning.');
        return CreateNewDiaryResponseDto(error: ErrorDetailsDto(errorCode: ErrorCode.GeneralException));
      }

      var isSuccess = await _updateDatabase(openDiaryDirId: openDiaryDir.id);
      if (isSuccess == false) {
        _logger.info('updateDatabase failed. rollback changes.');
        await _removeRemoteFile(remoteDiary.id);
        database.diary.remove(diary);
        _logger.info('rollback finished. returning.');
        return CreateNewDiaryResponseDto(error: ErrorDetailsDto(errorCode: ErrorCode.GeneralException));
      }

      return CreateNewDiaryResponseDto();
    } on ApiRequestError {

      return CreateNewDiaryResponseDto(error: ErrorDetailsDto(errorCode: ErrorCode.FileCreationFailure, errorMessage: 'File creation to google drive request failed.'));
    } on Exception catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());

      return CreateNewDiaryResponseDto(error: ErrorDetailsDto(errorCode: ErrorCode.GeneralException));
    }
  }

  Future<GetDiaryResponseDto> getDiaries({bool isHardRefresh = false}) async {
    _logger.info('getDiaries invoked.');
    ErrorDetailsDto error;
    // initialize if database has not initialize yet
    if (database == null || database != null && isHardRefresh == true) {
      _logger.info(database == null ? 'initialize database' : 'refreshing database');
      error = await initializeDatabase();
    }
    _logger.info('finished getdiaries.');
    return error != null ? GetDiaryResponseDto(error: error) : GetDiaryResponseDto(diaries: database.diary);
  }
}