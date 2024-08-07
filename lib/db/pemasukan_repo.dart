// part of 'DBservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/itemcard_mdl.dart';
import 'package:groom/model/struk_mdl.dart';

abstract class _PemasukanRepo {
  FirebaseFirestore db;
  _PemasukanRepo(this.db);

  ///----- Pemasukan ------
  Future<List<StrukMdl>> getAllStruk();
  Future<List<StrukMdl>> getStrukFiltered(Map filter);
  Future<DocumentReference> insertStruk(StrukMdl data);
  Future<DocumentReference> deleteStruk(StrukMdl data);

  ///------ end pemasukan ------
  ///
}

// class PemasukanRepository implements _PemasukanRepo {
//   PemasukanRepository({required this.db});
//   var storePemasukan = intMapStoreFactory.store('strukPemasukan');
//   var storeLainnya = intMapStoreFactory.store('storeLainnya');
//   var storePemasukanDeleted = intMapStoreFactory.store('strukPemasukanDeleted');
//   @override
//   Database db;

//   @override
//   Future<int> deleteStruk(StrukMdl data) async {
//     try {
//       var x = await db.transaction((tx) async {
//         await storePemasukanDeleted.add(tx, data.toJson());
//         var v = await storePemasukan.delete(tx,
//             finder: Finder(filter: Filter.byKey(data.id!)));
//         return v;
//       });
//       return x;
//     } catch (e) {
//       throw Exception(e);
//     }
//   }

//   Future<List<String>> getAllLainnya(String? query) {
//     return storeLainnya
//         .query(
//             finder: Finder(
//                 filter: Filter.matchesRegExp(
//                     'namaBarang', RegExp(query ?? '', caseSensitive: false))))
//         .getSnapshots(db)
//         .then((value) => value
//             .map((e) => ItemCardMdl.fromJson(e.value).namaBarang)
//             .toList());
//   }

//   @override
//   Future<List<StrukMdl>> getAllStruk() {
//     // var store = intMapStoreFactory.store('strukPemasukan');
//     return storePemasukan
//         .query(
//             finder: Finder(sortOrders: [
//           SortOrder('namaKaryawan'),
//           SortOrder('tanggal'),
//         ]))
//         .getSnapshots(db)
//         .then((value) {
//       if (value.isNotEmpty) {
//         return value
//             .map((e) => StrukMdl.fromJson(e.value).copyWith(id: () => e.key))
//             .toList();
//       } else {
//         return [];
//       }
//     });
//   }

//   @override
//   Future<List<StrukMdl>> getStrukFiltered(Map filter) {
//     var ts = (filter['tanggalStart'] as DateTime);
//     var te = (filter['tanggalEnd'] as DateTime);
//     // var fd = DateTime.now();

//     // var startTimestamp = Timestamp.fromDateTime(aye);
//     var startTimestamp =
//         Timestamp.fromDateTime(DateTime(ts.year, ts.month, ts.day));
//     var endTimestamp =
//         Timestamp.fromDateTime(DateTime(te.year, te.month, te.day));
//     var fil = [
//       Filter.greaterThanOrEquals('tanggal', startTimestamp),
//       Filter.lessThan('tanggal', endTimestamp),
//     ];
//     List<SortOrder> orders = [];
//     if (filter['order'] != null && filter['order'] == 'reverse') {
//       orders.add(SortOrder('tanggal', false));
//     } else {
//       orders.add(SortOrder('tanggal'));
//     }
//     return storePemasukan
//         .query(
//           finder: Finder(filter: Filter.and(fil), sortOrders: orders),
//         )
//         .getSnapshots(db)
//         .then((value) => value
//             .map((e) => StrukMdl.fromJson(e.value).copyWith(id: () => e.key))
//             .toList());
//   }

//   @override
//   Future<int> insertStruk(StrukMdl data) async {
//     // var store = intMapStoreFactory.store('strukPemasukan');
//     try {
//       for (ItemCardMdl ew in data.itemCards) {
//         if (ew.type == cardType.length - 1) {
//           await storeLainnya.add(db, ew.toJson());
//         }
//       }
//       return await storePemasukan.add(db, data.toJson());
//       // return await db.transaction((tx) async {
//       // });
//     } catch (e) {
//       return -1;
//     }
//   }
// }
class PemasukanRepository implements _PemasukanRepo {
  PemasukanRepository({required this.db});
  @override
  FirebaseFirestore db;

  @override
  Future<DocumentReference> deleteStruk(StrukMdl data) {
    return db
        .collection('strukMasuk')
        .doc(data.id)
        .delete()
        .then((value) async {
      return await db
          .collection('strukMasukDeleted')
          .add(data.toJson()..addAll({'time': DateTime.now().timestampFire}));
    });
  }

  @override
  Future<List<StrukMdl>> getAllStruk() {
    return db.collection('strukMasuk').get().then((value) => value.docs
        .map((e) => StrukMdl.fromJson(e.data()).copyWith(
              id: () => e.id,
              fromCache: () => e.metadata.isFromCache,
            ))
        .toList());
  }

  Future<List<String>> getAllLainnya(String? query) {
    return db.collection('strukLainnya').get().then((value) => value.docs
        .map((e) => ItemCardMdl.fromJson(e.data()).namaBarang)
        .toList());

    //     finder: Finder(
    //         filter: Filter.matchesRegExp(
    //             'namaBarang', RegExp(query ?? '', caseSensitive: false))))
    // .getSnapshots(db)
    // .then((value) => value
    //     .map((e) => ItemCardMdl.fromJson(e.value).namaBarang)
    //     .toList());
  }

  @override
  Future<List<StrukMdl>> getStrukFiltered(Map filter) {
    var ts = (filter['tanggalStart'] as DateTime);
    var te = (filter['tanggalEnd'] as DateTime);
    // var fd = DateTime.now();

    // var startTimestamp = Timestamp.fromDateTime(aye);
    var startTimestamp =
        Timestamp.fromDate(DateTime(ts.year, ts.month, ts.day));
    var endTimestamp = Timestamp.fromDate(DateTime(te.year, te.month, te.day));
    Query<Map<String, dynamic>> reff = db.collection('strukMasuk');
    for (var e in filter.entries) {
      switch (e.key) {
        case 'order' when e.value != null:
          reff = reff.orderBy('tanggal', descending: true);
          break;
        case 'tanggalStart' when !filter.keys.contains('tanggalEnd'):
          reff = reff.where('tanggal', isGreaterThanOrEqualTo: startTimestamp);
          break;
        case 'tanggalStart' when filter.keys.contains('tanggalEnd'):
          reff = reff.where(Filter.and(
              Filter('tanggal', isGreaterThanOrEqualTo: startTimestamp),
              Filter('tanggal', isLessThan: endTimestamp)));
          break;
        default:
      }
    }
    return reff.get().then((value) => value.docs
        .map((e) => StrukMdl.fromJson(e.data()).copyWith(
              id: () => e.id,
              fromCache: () => e.metadata.isFromCache,
            ))
        .toList());
    // var fil = [
    //   Filter.greaterThanOrEquals('tanggal', startTimestamp),
    //   Filter.lessThan('tanggal', endTimestamp),
    // ];
    // List<SortOrder> orders = [];
    ///---worked code below
    // if (filter['order'] != null && filter['order'] == 'reverse') {
    //   // orders.add(SortOrder('tanggal', false));
    //   return db
    //       .collection('strukMasuk')
    //       .where(Filter.and(
    //           Filter('tanggal', isGreaterThanOrEqualTo: startTimestamp),
    //           Filter('tanggal', isLessThan: endTimestamp)))
    //       .orderBy('tanggal', descending: true)
    //       .get()
    //       .then((value) => value.docs
    //           .map((e) => StrukMdl.fromJson(e.data()).copyWith(
    //                 id: () => e.id,
    //               ))
    //           .toList());
    // } else {
    //   // orders.add(SortOrder('tanggal'));
    //   return db
    //       .collection('strukMasuk')
    //       .where(Filter.and(
    //           Filter('tanggal', isGreaterThanOrEqualTo: startTimestamp),
    //           Filter('tanggal', isLessThan: endTimestamp)))
    //       .orderBy('tanggal')
    //       .get()
    //       .then((value) => value.docs
    //           .map((e) => StrukMdl.fromJson(e.data()).copyWith(
    //                 id: () => e.id,
    //               ))
    //           .toList());
    // }
    // return [];
    ///===end
    // return storePemasukan
    //     .query(
    //       finder: Finder(filter: Filter.and(fil), sortOrders: orders),
    //     )
    //     .getSnapshots(db)
    //     .then((value) => value
    //         .map((e) => StrukMdl.fromJson(e.value).copyWith(id: () => e.key))
    //         .toList());
  }

  @override
  Future<DocumentReference> insertStruk(StrukMdl data) {
    for (ItemCardMdl ew in data.itemCards) {
      if (ew.type == cardType.length - 1) {
        // await storeLainnya.add(db, ew.toJson());
        db.collection('strukLainnya').add(ew.toJson());
      }
    }
    var thedata = data.toJson();
    if (data.tipePembayaran == TipePembayaran.qris) {
      thedata.putIfAbsent(
        'midstatus',
        () => 'pending',
      );
    }
    return db.collection('strukMasuk').add(thedata);
  }
}
