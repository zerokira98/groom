part of 'DBservice.dart';

abstract class _KaryawanRepo {
  Database db;
  _KaryawanRepo(this.db);

  ///----- Karyawan data -----
  ///
  Future<List<KaryawanData>> getAllKaryawan();
  Future<List<KaryawanData>> getKaryawanFiltered(Filter filter);
  Future<int> addKaryawan(KaryawanData data);
  Future<int> deleteKaryawan(KaryawanData data);

  ///----- end karyawan -----
}

class KaryawanRepository implements _KaryawanRepo {
  KaryawanRepository({required this.db});

  @override
  Database db;

  StoreRef<int, Map<String, Object?>> storeKaryawan =
      intMapStoreFactory.store('karyawanData');

  @override
  Future<int> addKaryawan(KaryawanData data) {
    // var store = intMapStoreFactory.store('karyawanData');
    try {
      return storeKaryawan.add(db, data.toJson());
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<int> deleteKaryawan(KaryawanData data) {
    return storeKaryawan.delete(db,
        finder:
            Finder(filter: Filter.equals('namaKaryawan', data.namaKaryawan)));
  }

  @override
  Future<List<KaryawanData>> getAllKaryawan() {
    // var store = intMapStoreFactory.store('karyawanData');
    return storeKaryawan
        .query(finder: Finder(sortOrders: [SortOrder('namaKaryawan')]))
        .getSnapshots(db)
        .then((value) => value
            .map((e) => KaryawanData.fromJson(e.value).copyWith(id: e.key))
            .toList());
  }

  @override
  Future<List<KaryawanData>> getKaryawanFiltered(Filter filter) {
    return storeKaryawan
        .query(
            finder:
                Finder(filter: filter, sortOrders: [SortOrder('namaKaryawan')]))
        .getSnapshots(db)
        .then((value) => value
            .map((e) => KaryawanData.fromJson(e.value).copyWith(id: e.key))
            .toList());
  }
}
