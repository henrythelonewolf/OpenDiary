import 'dart:convert';
import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:opendiary/clients/GoogleHttpClient.dart';
import 'package:opendiary/locator/service_locator.dart';
import 'package:opendiary/models/Database.dart';

class LocalDatabaseProvider {
  GoogleSignIn _googleSignIn = locator<GoogleSignIn>();
  OpenDiaryDatabase database;

  Future<void> initializeDatabase() async {
    if (_googleSignIn.currentUser == null) {
      log("Severe error - user is not logged in");
      return;
    }
    var headers = await _googleSignIn.currentUser.authHeaders;
    var googleHttpClient = GoogleHttpClient(headers);
    var drive = DriveApi(googleHttpClient);
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

    var appFolderId = appFolder.id;
    query = """
      parents in '$appFolderId'
      and name = 'database.json'
    """;
    queryResults = await drive.files.list(q: query);
    fileList = queryResults?.files;
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

  Future<List<Diary>> getDiaries() async {
    if (database == null) {
      await initializeDatabase();
    }

    return database.diary;
  }
}