part of 'DBservice.dart';

abstract class _PemasukanRepo {
  Database db;
  _PemasukanRepo(this.db);

  ///----- Pemasukan ------
  Future<List<StrukMdl>> getAllStruk();
  Future<List<StrukMdl>> getStrukFiltered(Map filter);
  Future<int> insertStruk(StrukMdl data);
  Future<int> deleteStruk(StrukMdl data);

  ///------ end pemasukan ------
  ///
}

class PemasukanRepository implements _PemasukanRepo {
  PemasukanRepository({required this.db});
  var storePemasukan = intMapStoreFactory.store('strukPemasukan');
  var storeLainnya = intMapStoreFactory.store('storeLainnya');
  var storePemasukanDeleted = intMapStoreFactory.store('strukPemasukanDeleted');
  @override
  Database db;

  @override
  Future<int> deleteStruk(StrukMdl data) async {
    try {
      var x = await db.transaction((tx) async {
        await storePemasukanDeleted.add(tx, data.toJson());
        var v = await storePemasukan.delete(tx,
            finder: Finder(filter: Filter.byKey(data.id!)));
        return v;
      });
      return x;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<String>> getAllLainnya(String? query) {
    return storeLainnya
        .query(
            finder: Finder(
                filter: Filter.matchesRegExp(
                    'namaBarang', RegExp(query ?? '', caseSensitive: false))))
        .getSnapshots(db)
        .then((value) => value
            .map((e) => ItemCardMdl.fromJson(e.value).namaBarang)
            .toList());
  }

  @override
  Future<List<StrukMdl>> getAllStruk() {
    // var store = intMapStoreFactory.store('strukPemasukan');
    return storePemasukan
        .query(
            finder: Finder(sortOrders: [
          SortOrder('namaKaryawan'),
          SortOrder('tanggal'),
        ]))
        .getSnapshots(db)
        .then((value) {
      if (value.isNotEmpty) {
        return value
            .map((e) => StrukMdl.fromJson(e.value).copyWith(id: () => e.key))
            .toList();
      } else {
        return [];
      }
    });
  }

  @override
  Future<List<StrukMdl>> getStrukFiltered(Map filter) {
    var ts = (filter['tanggalStart'] as DateTime);
    var te = (filter['tanggalEnd'] as DateTime);
    // var fd = DateTime.now();

    // var startTimestamp = Timestamp.fromDateTime(aye);
    var startTimestamp =
        Timestamp.fromDateTime(DateTime(ts.year, ts.month, ts.day));
    var endTimestamp =
        Timestamp.fromDateTime(DateTime(te.year, te.month, te.day));

    return storePemasukan
        .query(
          finder: Finder(
              filter: Filter.and([
                Filter.greaterThanOrEquals('tanggal', startTimestamp),
                Filter.lessThan('tanggal', endTimestamp),
              ]),
              sortOrders: [SortOrder('tanggal')]),
        )
        .getSnapshots(db)
        .then((value) => value
            .map((e) => StrukMdl.fromJson(e.value).copyWith(id: () => e.key))
            .toList());
  }

  @override
  Future<int> insertStruk(StrukMdl data) async {
    // var store = intMapStoreFactory.store('strukPemasukan');
    try {
      for (ItemCardMdl ew in data.itemCards) {
        if (ew.type == cardType.length - 1) {
          await storeLainnya.add(db, ew.toJson());
        }
      }
      return await storePemasukan.add(db, data.toJson());
      // return await db.transaction((tx) async {
      // });
    } catch (e) {
      return -1;
    }
  }
}
