// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

// part 'barang_repo.dart';
// part 'pengeluaranRepo.dart';
// part 'karyawanRepo.dart';
// part 'pemasukanRepo.dart';
// part 'bonRepo.dart';
// part 'uangmasuk_repo.dart';

class SembastDB {
  static Future<Database> init() async {
// get the application documents directory
    var dir = await getApplicationDocumentsDirectory();
// make sure it exists
    await dir.create(recursive: true);
// build the database path
    var dbPath = join(dir.path, 'my_database.db');
// open the database
    return databaseFactoryIo.openDatabase(dbPath);
  }

  static Future<Database> init2() async {
// get the application documents directory
    var dir = await getApplicationDocumentsDirectory();
// make sure it exists
    await dir.create(recursive: true);
// build the database path
    var dbPath = join(dir.path, 'my_database2.db');
// open the database
    return databaseFactoryIo.openDatabase(dbPath);
  }
}
