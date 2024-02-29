// part of 'DBservice.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groom/model/karyawan_mdl.dart';
import 'package:sembast/sembast.dart' hide Filter;

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
  KaryawanRepository({required this.db, required this.firestore}) {
    ref = firestore.collection('karyawan').withConverter(
          fromFirestore: (snapshot, options) =>
              KaryawanData.fromJson(snapshot.data()!).copyWith(
            id: () => snapshot.id,
          ),
          toFirestore: (value, options) => value.toJson(),
        );
  }
  FirebaseFirestore firestore;
  late CollectionReference<KaryawanData> ref;
  @override
  Database db;

  StoreRef<int, Map<String, Object?>> storeKaryawan =
      intMapStoreFactory.store('karyawanData');

  @override
  Future<int> addKaryawan(KaryawanData data) {
    // var store = intMapStoreFactory.store('karyawanData');
    try {
      return ref
          .add(data)
          .then((value) => 1)
          .onError((error, stackTrace) => -1);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<int> deleteKaryawan(KaryawanData data) {
    return ref
        .doc(data.id)
        .delete()
        .then((value) => 1)
        .onError((error, stackTrace) => -1);
  }

  Future<int> update(KaryawanData data) {
    return ref
        .doc(data.id)
        .update(data.toJson())
        .then((value) => 1)
        .onError((error, stackTrace) => -1);
  }

  @override
  Future<List<KaryawanData>> getAllKaryawan([bool? first]) {
    // var store = intMapStoreFactory.store('karyawanData');
    GetOptions? getOptions =
        first == null ? const GetOptions(source: Source.cache) : null;
    return ref
        .orderBy('namaKaryawan')
        .get(getOptions)
        .then((value) => value.docs.map((e) => e.data()).toList());
    // return storeKaryawan
    //     .query(finder: Finder(sortOrders: [SortOrder('namaKaryawan')]))
    //     .getSnapshots(db)
    //     .then((value) => value
    //         .map((e) => KaryawanData.fromJson(e.value).copyWith(id: e.key))
    //         .toList());
  }

  @override
  Future<List<KaryawanData>> getKaryawanFiltered(Filter filter) {
    return ref
        .orderBy('namaKaryawan')
        .get()
        .then((value) => value.docs.map((e) => e.data()).toList());
    // return storeKaryawan
    //     .query(
    //         finder:
    //             Finder(filter: filter, sortOrders: [SortOrder('namaKaryawan')]))
    //     .getSnapshots(db)
    //     .then((value) => value
    //         .map((e) => KaryawanData.fromJson(e.value).copyWith(id: e.key))
    //         .toList());
  }
}
