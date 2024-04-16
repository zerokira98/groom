// part of 'DBservice.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:groom/model/ekuitas_mdl.dart';
// import 'package:sembast/sembast.dart' hide Filter;

abstract class _EkuitasRepo {
  // Database db;
  _EkuitasRepo();
  // var store = intMapStoreFactory.store('ekuitas');

  ///
  Future<List<EkuitasMdl>> getAll();
  Future<List<EkuitasMdl>> getFiltered(Filter filter);
  Future<int> add(EkuitasMdl data);
  Future<int> delete(EkuitasMdl data);
}

class EkuitasRepository extends _EkuitasRepo {
  late CollectionReference<EkuitasMdl> ref;
  FirebaseFirestore firestore;
  EkuitasRepository(this.firestore) {
    ref = firestore.collection('uangMasuk').withConverter(
          fromFirestore: (snapshot, options) =>
              EkuitasMdl.fromJson(snapshot.data()!).copyWith(
            id: () => snapshot.id,
          ),
          toFirestore: (value, options) => value.toJson(),
        );
  }

  @override
  Future<int> add(EkuitasMdl data) async {
    return ref.add(data).then((value) => 1).onError((error, stackTrace) {
      debugPrint(error.toString());
      return -1;
    });
    // return await store.add(db, data.toJson());
  }

  @override
  Future<int> delete(EkuitasMdl data) {
    return ref.doc(data.id).delete().then((value) {
      firestore.collection('uangMasukDeleted').add(data.toJson());
      return 1;
    }).onError((error, stackTrace) => -1);
    // return store.delete(db,
    //     finder: Finder(filter: Filter.equals('id', data.id)));
  }

  @override
  Future<List<EkuitasMdl>> getAll() {
    return ref.get().then((value) => value.docs.map((e) => e.data()).toList());
    // return store.query().getSnapshots(db).then((value) => value
    //     .map((e) => EkuitasMdl.fromJson(e.value).copyWith(id: () => e.key))
    //     .toList());
  }

  @override
  Future<List<EkuitasMdl>> getFiltered(Filter filter) {
    throw UnimplementedError();
  }
}
