// part of 'DBservice.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groom/model/pengeluaran_mdl.dart';
import 'package:sembast/sembast.dart' as s;

abstract class _PengeluaranRepo {
  FirebaseFirestore firestore;
  _PengeluaranRepo(this.firestore);

  Future<List<PengeluaranMdl>> getAll();
  Future<List<PengeluaranMdl>> getFiltered(
      {required DateTime tglStart, required DateTime tglEnd});
  Future<int> insert(PengeluaranMdl data);
  Future<int> delete(PengeluaranMdl data);
}

// class PengeluaranRepository implements _PengeluaranRepo {
//   PengeluaranRepository({required this.db});
//   var storePengeluaran = intMapStoreFactory.store('strukPengeluaran');
//   var storePengeluaranDeleted =
//       intMapStoreFactory.store('strukPengeluaranDeleted');
//   var storePengeluaranNama = intMapStoreFactory.store('namaPengeluaran');
//   @override
//   Database db;
//   Future typeAhead(String text) async {}
//   @override
//   Future<int> delete(PengeluaranMdl data) async {
//     try {
//       var x = await db.transaction((tx) async {
//         await storePengeluaranDeleted.add(tx, data.toJson());
//         var v = await storePengeluaran.delete(tx,
//             finder: Finder(filter: Filter.byKey(data.id!)));
//         return v;
//       });
//       return x;
//     } catch (e) {
//       throw Exception(e);
//     }
//   }

//   @override
//   Future<List<PengeluaranMdl>> getAll() {
//     return storePengeluaran
//         .query(
//             finder: Finder(sortOrders: [
//           SortOrder('namaPengeluaran'),
//           SortOrder('tanggal'),
//         ]))
//         .getSnapshots(db)
//         .then((value) {
//       if (value.isNotEmpty) {
//         return value
//             .map((e) =>
//                 PengeluaranMdl.fromJson(e.value).copyWith(id: () => e.key))
//             .toList();
//       } else {
//         return [];
//       }
//     });
//   }

//   Future<List<PengeluaranMdl>> getByKaryawan(String karyawan) {
//     return storePengeluaran
//         .query(
//             finder: Finder(
//                 filter: Filter.equals('karyawan', karyawan),
//                 sortOrders: [
//               SortOrder('namaPengeluaran'),
//               SortOrder('tanggal'),
//             ]))
//         .getSnapshots(db)
//         .then((value) {
//       if (value.isNotEmpty) {
//         return value
//             .map((e) =>
//                 PengeluaranMdl.fromJson(e.value).copyWith(id: () => e.key))
//             .toList();
//       } else {
//         return [];
//       }
//     });
//   }

//   Future<List<String>> getAutoComplete(
//       String query, TipePengeluaran tipe) async {
//     switch (tipe.index) {
//       case 1:
//         return getOperational(query);
//       // break;
//       case 2:
//         return getNamaBarang(query);
//       // break;
//       default:
//         return [];
//     }
//   }

//   Future<List<String>> getNamaBarang(String queryText) async {
//     return storePengeluaran
//         .query(
//             finder: Finder(
//                 filter: Filter.and([
//           Filter.equals('tipePengeluaran', 'barangjual'),
//           Filter.matchesRegExp(
//               'namaPengeluaran',
//               RegExp(
//                 queryText,
//                 caseSensitive: false,
//               ))
//         ])))
//         .getSnapshots(db)
//         .then((value) => value
//             .map((e) => e.value['namaPengeluaran'] as String)
//             .toSet()
//             .toList());
//   }

//   Future<List<String>> getOperational(String queryText) async {
//     return storePengeluaran
//         .query(
//             finder: Finder(
//                 filter: Filter.and([
//           Filter.equals('tipePengeluaran', 'operasional'),
//           Filter.matchesRegExp(
//               'namaPengeluaran',
//               RegExp(
//                 queryText,
//                 caseSensitive: false,
//               ))
//         ])))
//         .getSnapshots(db)
//         .then((value) =>
//             value.map((e) => e.value['namaPengeluaran'] as String).toList());
//   }

//   Future<List<PengeluaranMdl>> getByOrder(TipePengeluaran? tipe,
//       {DateTime? starts, DateTime? ends}) {
//     Timestamp? start = starts == null
//         ? null
//         : Timestamp.fromDateTime(DateUtils.dateOnly(starts));
//     Timestamp? end = ends == null
//         ? starts == null
//             ? null
//             : Timestamp.fromDateTime(
//                 DateUtils.dateOnly(starts.add(Duration(days: 1))))
//         : Timestamp.fromDateTime(DateUtils.dateOnly(ends));
//     List<Filter> filters = [];
//     if (tipe != null) {
//       filters.add(Filter.equals('tipePengeluaran', tipe.name));
//     }
//     if (starts != null) {
//       filters.add(Filter.greaterThanOrEquals('tanggal', start));
//       if (ends != null) {
//         filters.add(Filter.lessThan('tanggal', end));
//       } else {
//         filters.add(Filter.lessThan('tanggal', end));
//       }
//     }

//     return storePengeluaran
//         .query(
//             finder: Finder(
//                 filter: Filter.and(filters),
//                 sortOrders: [SortOrder('tanggal')]))
//         .getSnapshots(db)
//         .then((value) => value
//             .map((e) =>
//                 PengeluaranMdl.fromJson(e.value).copyWith(id: () => e.key))
//             .toList());
//   }

//   Future<List<PengeluaranMdl>> getOperasionalOnly({
//     required DateTime tgl,
//   }) {
//     var startTimestamp =
//         Timestamp.fromDateTime(DateTime(tgl.year, tgl.month, tgl.day));
//     var endTimestamp =
//         Timestamp.fromDateTime(DateTime(tgl.year, tgl.month, tgl.day + 1));
//     return storePengeluaran
//         .query(
//             finder: Finder(
//                 filter: Filter.and([
//           Filter.greaterThanOrEquals('tanggal', startTimestamp),
//           Filter.lessThan('tanggal', endTimestamp),
//           Filter.equals('tipePengeluaran', 'operasional')
//         ])))
//         .getSnapshots(db)
//         .then((value) => value
//             .map((e) => PengeluaranMdl.fromJson(e.value).copyWith(
//                   id: () => e.key,
//                 ))
//             .toList());
//   }

//   @override
//   Future<List<PengeluaranMdl>> getFiltered(
//       {required DateTime tglStart, required DateTime tglEnd}) {
//     var ts = (tglStart);
//     var te = (tglEnd);

//     var startTimestamp =
//         Timestamp.fromDateTime(DateTime(ts.year, ts.month, ts.day));
//     var endTimestamp =
//         Timestamp.fromDateTime(DateTime(te.year, te.month, te.day));

//     return storePengeluaran
//         .query(
//           finder: Finder(
//               filter: Filter.and([
//                 Filter.greaterThanOrEquals('tanggal', startTimestamp),
//                 Filter.lessThan('tanggal', endTimestamp),
//               ]),
//               sortOrders: [SortOrder('tanggal')]),
//         )
//         .getSnapshots(db)
//         .then((value) => value
//             .map((e) =>
//                 PengeluaranMdl.fromJson(e.value).copyWith(id: () => e.key))
//             .toList());
//   }

//   @override
//   Future<int> insert(PengeluaranMdl data) async {
//     try {
//       var exist = await storePengeluaranNama
//           .query(finder: Finder(filter: Filter.equals('nama', data)))
//           .getSnapshots(db);
//       if (exist.isEmpty) {
//         await storePengeluaranNama.add(db, {'nama': data.namaPengeluaran});
//       }
//       // return 0;
//       return await storePengeluaran.add(db, data.toJson());
//     } catch (e) {
//       return -1;
//     }
//   }
// }
class PengeluaranRepository implements _PengeluaranRepo {
  late CollectionReference<PengeluaranMdl> storeRef;
  PengeluaranRepository({required this.firestore, required this.db}) {
    storeRef = firestore.collection('pengeluaran').withConverter(
          fromFirestore: (snapshot, options) =>
              PengeluaranMdl.fromJson(snapshot.data()!).copyWith(
            id: () => snapshot.id,
          ),
          toFirestore: (value, options) => value.toJson(),
        );
  }
  @override
  FirebaseFirestore firestore;
  s.Database db;
  var storePengeluaran = s.intMapStoreFactory.store('strukPengeluaran');

  @override
  Future<int> delete(PengeluaranMdl data) {
    return storeRef
        .doc(data.id)
        .delete()
        .then((value) => 1)
        .onError((error, stackTrace) => -1);
  }

  @override
  Future<List<PengeluaranMdl>> getAll() {
    return storeRef
        .get()
        .then((value) => value.docs.map((e) => e.data()).toList());
  }

  @override
  Future<List<PengeluaranMdl>> getFiltered(
      {required DateTime tglStart, required DateTime tglEnd}) {
    var ts = (tglStart);
    var te = (tglEnd);

    var startTimestamp =
        Timestamp.fromDate(DateTime(ts.year, ts.month, ts.day));
    var endTimestamp = Timestamp.fromDate(DateTime(te.year, te.month, te.day));
    return storeRef
        .where(Filter.and(
            Filter('tanggal', isGreaterThanOrEqualTo: startTimestamp),
            Filter('tanggal', isLessThan: endTimestamp)))
        .get()
        .then((value) => value.docs.map((e) => e.data()).toList());
  }

  Future<List<String>> getAutoComplete(
      String query, TipePengeluaran tipe) async {
    switch (tipe.index) {
      case 1:
        return getOperational(query);
      // break;
      case 2:
        return getNamaBarang(query);
      // break;
      case 0:
        return firestore.collection('karyawan').get().then((value) =>
            value.docs.map((e) => e.data()['namaKaryawan'] as String).toList());
      // break;
      default:
        return [];
    }
  }

  Future<List<String>> getNamaBarang(String queryText) async {
    return storeRef
        .where((Filter('tipePengeluaran', isEqualTo: 'barangjual')))
        .get()
        .then((value) => value.docs
            .map((e) => RegExp(queryText, caseSensitive: false)
                    .hasMatch(e.data().namaPengeluaran)
                ? e.data().namaPengeluaran
                : null)
            .nonNulls
            .toList());
  }

  Future<List<String>> getOperational(String queryText) async {
    return storeRef
        .where((Filter('tipePengeluaran', isEqualTo: 'operasional')))
        .get()
        .then((value) => value.docs
            .map((e) => RegExp(queryText, caseSensitive: false)
                    .hasMatch(e.data().namaPengeluaran)
                ? e.data().namaPengeluaran
                : null)
            .nonNulls
            .toList());
  }

  Future<List<PengeluaranMdl>> getByKaryawan(String karyawan,
      [DateTime? tanggal]) {
    return storeRef
        .where('karyawan', isEqualTo: karyawan)
        .where('tanggal', isGreaterThanOrEqualTo: tanggal)
        .orderBy('tanggal')
        .get()
        .then((value) => value.docs.map((e) => e.data()).toList());
    // return storePengeluaran
    //     .query(
    //         finder: Finder(
    //             filter: Filter.equals('karyawan', karyawan),
    //             sortOrders: [
    //           SortOrder('namaPengeluaran'),
    //           SortOrder('tanggal'),
    //         ]))
    //     .getSnapshots(db)
    //     .then((value) {
    //   if (value.isNotEmpty) {
    //     return value
    //         .map((e) =>
    //             PengeluaranMdl.fromJson(e.value).copyWith(id: () => e.key))
    //         .toList();
    //   } else {
    //     return [];
    //   }
    // });
  }

  Future<List<PengeluaranMdl>> getByOrder(TipePengeluaran? tipe,
      {DateTime? starts, DateTime? ends}) {
    Timestamp? start =
        starts == null ? null : Timestamp.fromDate(DateUtils.dateOnly(starts));
    Timestamp? end = ends == null
        ? starts == null
            ? null
            : Timestamp.fromDate(
                DateUtils.dateOnly(starts.add(const Duration(days: 1))))
        : Timestamp.fromDate(DateUtils.dateOnly(ends));

    if (tipe != null) {
      if (starts != null) {
        return storeRef
            // .where()
            .where(Filter.and(
              Filter('tipePengeluaran', isEqualTo: tipe.name),
              Filter('tanggal', isGreaterThanOrEqualTo: start),
              Filter('tanggal', isLessThan: end),
            ))
            .get()
            .then((value) => value.docs.map((e) => e.data()).toList());
      }
      return storeRef
          .where(Filter('tipePengeluaran', isEqualTo: tipe.name))
          .get()
          .then((value) => value.docs.map((e) => e.data()).toList());
    } else if (starts != null) {
      return storeRef
          .where(Filter('tanggal', isGreaterThanOrEqualTo: start))
          .get()
          .then((value) => value.docs.map((e) => e.data()).toList());
    } else {}
    return storeRef
        // .where(Filter('tipePengeluaran',
        //     isEqualTo: tipe?.name ?? TipePengeluaran.operasional))
        .get()
        .then((value) => value.docs.map((e) => e.data()).toList());
    // return storePengeluaran
    //     .query(
    //         finder: Finder(
    //             filter: Filter.and(filters),
    //             sortOrders: [SortOrder('tanggal')]))
    //     .getSnapshots(db)
    //     .then((value) => value
    //         .map((e) =>
    //             PengeluaranMdl.fromJson(e.value).copyWith(id: () => e.key))
    //         .toList());
  }

  Future<List<PengeluaranMdl>> getOperasionalOnly({
    required DateTime tgl,
  }) {
    var startTimestamp =
        Timestamp.fromDate(DateTime(tgl.year, tgl.month, tgl.day));
    var endTimestamp =
        Timestamp.fromDate(DateTime(tgl.year, tgl.month, tgl.day + 1));
    return storeRef
        .where(Filter.and(
            Filter('tipePengeluaran', isEqualTo: 'operasional'),
            Filter('tanggal', isGreaterThanOrEqualTo: startTimestamp),
            Filter('tanggal', isLessThan: endTimestamp)))
        .get()
        .then((value) => value.docs.map((e) => e.data()).toList());
    // return storePengeluaran
    //     .query(
    //         finder: Finder(
    //             filter: Filter.and([
    //       Filter.greaterThanOrEquals('tanggal', startTimestamp),
    //       Filter.lessThan('tanggal', endTimestamp),
    //       Filter.equals('tipePengeluaran', 'operasional')
    //     ])))
    //     .getSnapshots(db)
    //     .then((value) => value
    //         .map((e) => PengeluaranMdl.fromJson(e.value).copyWith(
    //               id: () => e.key,
    //             ))
    //         .toList());
  }

  @override
  Future<int> insert(PengeluaranMdl data) {
    return firestore
        .collection('pengeluaran')
        .add(data.copyWith(tanggalPost: DateTime.now()).toJson())
        .then((value) {
      return 1;
    }).onError((error, stackTrace) => -1);
  }
}
