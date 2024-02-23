part of 'db_service.dart';

class BarangRepository {
  final StoreRef<int, Map<String, Object?>> _storeRef =
      intMapStoreFactory.store('barang');
  late CollectionReference<BarangMdl> ref;
  FirebaseFirestore firestore;
  BarangRepository({required this.db, required this.firestore}) {
    ref = firestore.collection('barang').withConverter(
          fromFirestore: (snapshot, options) =>
              BarangMdl.fromJson(snapshot.data()!).copyWith(
            id: () => snapshot.id,
          ),
          toFirestore: (value, options) => value.toJson(),
        );
  }
  Database db;
  Future<int> edit(BarangMdl data) {
    return ref
        .doc(data.id)
        .update(data.toJson())
        .then((value) => 1)
        .onError((error, stackTrace) => -1);
    // return _storeRef.update(db, data.toJson(),
    //     finder: Finder(filter: Filter.byKey(data.id)));
  }

  Future<int> add(BarangMdl data) {
    return ref.add(data).then((value) => 1).onError((error, stackTrace) => -1);
  }

  Future<int> delete(BarangMdl data) {
    return ref
        .doc(data.id)
        .delete()
        .then((value) => 1)
        .onError((error, stackTrace) => -1);
    // return _storeRef.delete(db, finder: Finder(filter: Filter.byKey(data.id)));
  }

  Future<List<BarangMdl>> getAll() async {
    return ref.get().then((value) => value.docs.map((e) => e.data()).toList());
    // return _storeRef.query().getSnapshots(db).then((value) => value
    //     .map((e) => BarangMdl.fromJson(e.value).copyWith(
    //           id: () => e.key,
    //         ))
    //     .toList());
  }

  Future<List<BarangMdl>> find(String namaBarang) async {
    return ref
        .where('namaBarrang', isEqualTo: namaBarang)
        .get()
        .then((value) => value.docs.map((e) => e.data()).toList());
    // return _storeRef
    //     .query(finder: Finder(filter: Filter.equals('namaBarang', namaBarang)))
    //     .getSnapshots(db)
    //     .then((value) => value
    //         .map((e) => BarangMdl.fromJson(e.value).copyWith(id: () => e.key))
    //         .toList());
  }
}
