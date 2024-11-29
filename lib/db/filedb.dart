import 'dart:io';
import 'dart:math';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileRepo {
  FileRepo();
  Future<File> getFileFromUrl({String? path}) async {
    var dir = await getApplicationDocumentsDirectory();
    var theFile = File(join(dir.path, path ?? ''));
    if (await theFile.exists()) {
      return theFile;
    } else {
      throw Exception('File not found');
    }
  }

  ///return filepath
  Future<String> uploadFile(File file, String filename) async {
    var dir = await getApplicationDocumentsDirectory();
    var newfilename = generateRandomString(6) + filename;
    // var theFile = File(join(dir.path, newfilename ));
    return file.copy(join(dir.path, newfilename, extension(file.path))).then(
      (value) {
        return value.path;
      },
    );
  }
}

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89));
}
