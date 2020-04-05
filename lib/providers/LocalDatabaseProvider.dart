import 'dart:convert';
import 'dart:io' as IO;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:logging/logging.dart';
import 'package:opendiary/clients/GoogleHttpClient.dart';
import 'package:opendiary/constants/error_constants.dart';
import 'package:opendiary/dto/ErrorDetailsDto.dart';
import 'package:opendiary/dto/database/CreateNewDiaryDto.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/models/Database.dart';

class LocalDatabaseProvider {
  final _logger = Logger('LocalDatabaseProvider');
  GoogleSignIn _googleSignIn = locator<GoogleSignIn>();
  OpenDiaryDatabase database;
  DriveApi drive;

  Future<bool> _initializeDriveApi() async {
    try {
      if (_googleSignIn.currentUser == null) {
        _logger.severe("error - user is not logged in");
        return false;
      }
      var headers = await _googleSignIn.currentUser.authHeaders;
      var googleHttpClient = GoogleHttpClient(headers);
      drive = DriveApi(googleHttpClient);
      
      return true;
    } on Exception catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());

      return false;
    }
  }

  Future<File> _fetchOpenDiaryDirectory() async {
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
    return appFolder;
  }

  Future<File> _fetchDiaryDirectory(String openDiaryDirId) async {
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
    return diaryDirectory;
  }

  Future<bool> _updateDatabase({String openDiaryDirId}) async {
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
        return false;
      }

      var contents = this.database.toJson();
      var bytes = utf8.encode(contents);
      var byteStream = Stream.fromIterable([bytes]);
      var newDatabase = File()
      ..name = database.name
      ..mimeType = database.mimeType;
      await drive.files.update(newDatabase, database.id, uploadMedia: Media(byteStream, bytes.length));
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
      var file = IO.File(localPath);
      var media = Media(file.openRead(), file.lengthSync());
      var metadata = File()
      ..name = filename
      ..mimeType = mimeType
      ..parents = [driveParentDir];

      var uploaded = await drive.files.create(metadata, uploadMedia: media);
      _logger.info('uploaded file $uploaded.');
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
      await drive.files.delete(fileId);
    } on Exception catch (error, stack) {
      _logger.severe(error.toString());
      _logger.severe(stack.toString());
    }
  }
  
  Future<void> initializeDatabase() async {
    var isSuccess;
    
    if (drive == null) {
      isSuccess = await _initializeDriveApi();
    }

    if (isSuccess == false) {
      return;
    }

    var appFolder = await _fetchOpenDiaryDirectory();
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
      // var file = io.File('database.json');
      // await file.writeAsString(contents);
      var bytes = utf8.encode(contents);
      var byteStream = Stream.fromIterable([bytes]);
      database = await drive.files.create(metadata, uploadMedia: Media(byteStream, bytes.length));
    }

    Media databaseObj = await drive.files.get(database.id, downloadOptions: DownloadOptions.FullMedia);
    var remoteContents = await readDatabaseContent(databaseObj);
    this.database = OpenDiaryDatabase.fromJson(remoteContents);
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
      if (diary == null) {
        return null;
      }
      database.diary.add(diary);

      var openDiaryDir = await _fetchOpenDiaryDirectory();
      var diaryDir = await _fetchDiaryDirectory(openDiaryDir.id);
      if (diaryDir == null) {
        return CreateNewDiaryResponseDto(error: ErrorDetailsDto(errorCode: ErrorCode.NotFound, errorMessage: 'opendiary/diary directory not found in user drive.'));
      }

      var remoteDiary = await _writeFileToDrive(diary.filename, path, diaryDir.id, mimeType: 'text/plain');
      if (remoteDiary == null) {
        return CreateNewDiaryResponseDto(error: ErrorDetailsDto(errorCode: ErrorCode.GeneralException));
      }

      var isSuccess = await _updateDatabase(openDiaryDirId: openDiaryDir.id);
      if (isSuccess == false) {
        await _removeRemoteFile(remoteDiary.id);
        database.diary.remove(diary);
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

  Future<List<Diary>> getDiaries() async {
    if (database == null) {
      await initializeDatabase();
    }

    return database.diary;
  }
}