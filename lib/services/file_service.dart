import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileService {
  Future<void> write(String fileName, String contents) async {
    final file = await _getFile(fileName);
    file.openWrite(mode: FileMode.write);
    await file.writeAsString(contents);
  }

  Future<String> read(String fileName) async {
    final file = await _getFile(fileName);
    if (await file.exists()) {
      await file.open(mode: FileMode.read);
      final contents = await file.readAsString();
      return contents;
    }
    return '';
  }

  Future<void> delete(String fileName) async {
    final file = await _getFile(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _getFile(String fileName) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final path = '${appDocDir.path}/$fileName';
    return File(path);
  }
}