import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/model.dart';

abstract class _BonRepo {
  FirebaseFirestore db;
  _BonRepo(this.db);

  //////----- Bon data -----
  ///
  Future<List<BonData>> getAllBon();
  Future<List<BonData>> getBonFiltered(Filter filter);
  Future<String> addBon(BonData data);
  Future deleteBon(BonData data);

  ///----- end karyawan -----
}

// class BonRepository implements _BonRepo {
//   StoreRef<int, Map<String, Object?>> storeBon =
//       intMapStoreFactory.store('bonData');
//   BonRepository({required this.db});
//   @override
//   Database db;

//   @override
//   Future<int> addBon(BonData data) {
//     return storeBon.add(db, data.toJson());
//   }

//   @override
//   Future<int> deleteBon(BonData data) {
//     return storeBon.delete(db, finder: Finder(filter: Filter.byKey(100990)));
//   }

//   @override
//   Future<List<BonData>> getAllBon() async {
//     return storeBon.query().getSnapshots(db).then((value) => value
//         .map((e) => BonData.fromJson(e.value).copyWith(idKey: () => e.key))
//         .toList());
//   }

//   Future<List<BonData>> getByNama(
//       {required String nama, DateTime? tgl, DateTime? tglEnd}) async {
//     var fil = [Filter.equals('namaSubjek', nama)];
//     if (tgl != null && tglEnd == null) {
//       var sd = Timestamp.fromDateTime(DateUtils.dateOnly(tgl));
//       var ed = Timestamp.fromDateTime(
//           DateUtils.dateOnly(tgl).add(Duration(days: 1)));
//       fil.add(Filter.greaterThanOrEquals('tanggal', sd));
//       fil.add(Filter.lessThan('tanggal', ed));
//       fil.add(Filter.equals('tipe', 'berhutang'));
//     }
//     if (tgl != null && tglEnd != null) {
//       var sd = Timestamp.fromDateTime(DateUtils.dateOnly(tgl));
//       var ed = Timestamp.fromDateTime(
//           DateUtils.dateOnly(tglEnd).add(Duration(days: 1)));
//       fil.add(Filter.greaterThanOrEquals('tanggal', sd));
//       fil.add(Filter.lessThan('tanggal', ed));
//     }
//     return storeBon
//         .query(finder: Finder(filter: Filter.and(fil)))
//         .getSnapshots(db)
//         .then((value) => value
//             .map((e) => BonData.fromJson(e.value).copyWith(
//                   idKey: () => e.key,
//                 ))
//             .toList());
//   }

//   @override
//   Future<List<BonData>> getBonFiltered(Filter filter) {
//     return storeBon.query(finder: Finder(filter: filter)).getSnapshots(db).then(
//         (value) => value
//             .map((e) => BonData.fromJson(e.value).copyWith(idKey: () => e.key))
//             .toList());
//   }
// }

class BonRepository implements _BonRepo {
  BonRepository({required this.db});
  @override
  FirebaseFirestore db;

  @override
  Future<String> addBon(BonData data) {
    return db
        .collection('bon')
        .add(data.toJson())
        .then((DocumentReference doc) {
      debugPrint('DocumentSnapshot added with ID: ${doc.id}');
      return doc.id;
    });
  }

  @override
  Future deleteBon(BonData data) {
    return db.collection('bon').doc(data.idKey).delete();
  }

  @override
  Future<List<BonData>> getAllBon() {
    return db.collection('bon').get().then(
        (value) => value.docs.map((e) => BonData.fromJson(e.data())).toList());
  }

  @override
  Future<List<BonData>> getBonFiltered(Filter filter) {
    return db.collection('bon').where(filter).get().then((value) => value.docs
        .map((e) => BonData.fromJson(e.data()).copyWith(idKey: () => e.id))
        .toList());
  }

  Future<List<BonData>> getByNama(
      {required String nama, DateTime? tgl, DateTime? tglEnd}) async {
    // var fil = [Filter('namaSubjek', isEqualTo: nama)];
    if (tgl != null && tglEnd == null) {
      var sd = Timestamp.fromDate(DateUtils.dateOnly(tgl));
      var ed = Timestamp.fromDate(
          DateUtils.dateOnly(tgl).add(const Duration(days: 1)));
      return db
          .collection('bon')
          .where(Filter.and(
              Filter('tanggal', isGreaterThanOrEqualTo: sd),
              Filter('tanggal', isLessThan: ed),
              Filter('namaSubjek', isEqualTo: nama)))
          // .where(Filter('tipe', isEqualTo: 'berhutang'))
          .get()
          .then((value) => value.docs
              .map(
                  (e) => BonData.fromJson(e.data()).copyWith(idKey: () => e.id))
              .toList());
    }
    if (tgl != null && tglEnd != null) {
      var sd = Timestamp.fromDate(DateUtils.dateOnly(tgl));
      var ed = Timestamp.fromDate(
          DateUtils.dateOnly(tglEnd).add(const Duration(days: 1)));
      return db
          .collection('bon')
          .where(Filter.and(
              Filter('tanggal', isGreaterThanOrEqualTo: sd),
              Filter('tanggal', isLessThan: ed),
              Filter('namaSubjek', isEqualTo: nama)))
          .get()
          .then((value) => value.docs
              .map(
                  (e) => BonData.fromJson(e.data()).copyWith(idKey: () => e.id))
              .toList());
    } else {
      return db
          .collection('bon')
          .where(Filter('namaSubjek', isEqualTo: nama))
          .get()
          .then((value) => value.docs
              .map(
                  (e) => BonData.fromJson(e.data()).copyWith(idKey: () => e.id))
              .toList());
    }
  }
}
