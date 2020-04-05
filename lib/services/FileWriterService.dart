import 'dart:io';

import 'package:opendiary/interfaces/services/IFileWriterService.dart';

class FileWriterService implements IFileWriterService {
  Future<File> writeToFile(File file, {String content = '', String title = ''}) async {
    String buffer = '';
    if (title != '' && title != null) {
      title = title.replaceAll('\n', '');
      buffer += '$title\n';
    }

    buffer += content;
    await file.writeAsString(buffer);
    return file;
  }
}