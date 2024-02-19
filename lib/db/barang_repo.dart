part of 'DBservice.dart';

class BarangRepository {
  final StoreRef<int, Map<String, Object?>> _storeRef =
      intMapStoreFactory.store('barang');
  BarangRepository({required this.db});
  Database db;
  Future<int> edit(BarangMdl data) {
    return _storeRef.update(db, data.toJson(),
        finder: Finder(filter: Filter.byKey(data.id)));
  }

  Future<int> add(BarangMdl data) {
    return _storeRef.add(db, data.toJson());
  }

  Future<int> delete(BarangMdl data) {
    return _storeRef.delete(db, finder: Finder(filter: Filter.byKey(data.id)));
  }

  Future<List<BarangMdl>> getAll() async {
    return _storeRef.query().getSnapshots(db).then((value) => value
        .map((e) => BarangMdl.fromJson(e.value).copyWith(
              id: () => e.key,
            ))
        .toList());
  }

  Future<List<BarangMdl>> find(String namaBarang) async {
    return _storeRef
        .query(finder: Finder(filter: Filter.equals('namaBarang', namaBarang)))
        .getSnapshots(db)
        .then((value) => value
            .map((e) => BarangMdl.fromJson(e.value).copyWith(id: () => e.key))
            .toList());
  }
}
