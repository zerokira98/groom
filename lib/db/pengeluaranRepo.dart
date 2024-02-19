part of 'DBservice.dart';

abstract class _PengeluaranRepo {
  Database db;
  _PengeluaranRepo(this.db);

  Future<List<PengeluaranMdl>> getAll();
  Future<List<PengeluaranMdl>> getFiltered(
      {required DateTime tglStart, required DateTime tglEnd});
  Future<int> insert(PengeluaranMdl data);
  Future<int> delete(PengeluaranMdl data);
}

class PengeluaranRepository implements _PengeluaranRepo {
  PengeluaranRepository({required this.db});
  var storePengeluaran = intMapStoreFactory.store('strukPengeluaran');
  var storePengeluaranDeleted =
      intMapStoreFactory.store('strukPengeluaranDeleted');
  var storePengeluaranNama = intMapStoreFactory.store('namaPengeluaran');
  @override
  Database db;
  Future typeAhead(String text) async {}
  @override
  Future<int> delete(PengeluaranMdl data) async {
    try {
      var x = await db.transaction((tx) async {
        await storePengeluaranDeleted.add(tx, data.toJson());
        var v = await storePengeluaran.delete(tx,
            finder: Finder(filter: Filter.byKey(data.id!)));
        return v;
      });
      return x;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<PengeluaranMdl>> getAll() {
    return storePengeluaran
        .query(
            finder: Finder(sortOrders: [
          SortOrder('namaPengeluaran'),
          SortOrder('tanggal'),
        ]))
        .getSnapshots(db)
        .then((value) {
      if (value.isNotEmpty) {
        return value
            .map((e) =>
                PengeluaranMdl.fromJson(e.value).copyWith(id: () => e.key))
            .toList();
      } else {
        return [];
      }
    });
  }

  Future<List<PengeluaranMdl>> getByKaryawan(String karyawan) {
    return storePengeluaran
        .query(
            finder: Finder(
                filter: Filter.equals('karyawan', karyawan),
                sortOrders: [
              SortOrder('namaPengeluaran'),
              SortOrder('tanggal'),
            ]))
        .getSnapshots(db)
        .then((value) {
      if (value.isNotEmpty) {
        return value
            .map((e) =>
                PengeluaranMdl.fromJson(e.value).copyWith(id: () => e.key))
            .toList();
      } else {
        return [];
      }
    });
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
      default:
        return [];
    }
  }

  Future<List<String>> getNamaBarang(String queryText) async {
    return storePengeluaran
        .query(
            finder: Finder(
                filter: Filter.and([
          Filter.equals('tipePengeluaran', 'barangjual'),
          Filter.matchesRegExp(
              'namaPengeluaran',
              RegExp(
                queryText,
                caseSensitive: false,
              ))
        ])))
        .getSnapshots(db)
        .then((value) => value
            .map((e) => e.value['namaPengeluaran'] as String)
            .toSet()
            .toList());
  }

  Future<List<String>> getOperational(String queryText) async {
    return storePengeluaran
        .query(
            finder: Finder(
                filter: Filter.and([
          Filter.equals('tipePengeluaran', 'operasional'),
          Filter.matchesRegExp(
              'namaPengeluaran',
              RegExp(
                queryText,
                caseSensitive: false,
              ))
        ])))
        .getSnapshots(db)
        .then((value) =>
            value.map((e) => e.value['namaPengeluaran'] as String).toList());
  }

  Future<List<PengeluaranMdl>> getByOrder(TipePengeluaran? tipe,
      {DateTime? starts, DateTime? ends}) {
    Timestamp? start = starts == null
        ? null
        : Timestamp.fromDateTime(DateUtils.dateOnly(starts));
    Timestamp? end = ends == null
        ? starts == null
            ? null
            : Timestamp.fromDateTime(
                DateUtils.dateOnly(starts.add(Duration(days: 1))))
        : Timestamp.fromDateTime(DateUtils.dateOnly(ends));
    List<Filter> filters = [];
    if (tipe != null) {
      filters.add(Filter.equals('tipePengeluaran', tipe.name));
    }
    if (starts != null) {
      filters.add(Filter.greaterThanOrEquals('tanggal', start));
      if (ends != null) {
        filters.add(Filter.lessThan('tanggal', end));
      } else {
        filters.add(Filter.lessThan('tanggal', end));
      }
    }

    return storePengeluaran
        .query(
            finder: Finder(
                filter: Filter.and(filters),
                sortOrders: [SortOrder('tanggal')]))
        .getSnapshots(db)
        .then((value) => value
            .map((e) =>
                PengeluaranMdl.fromJson(e.value).copyWith(id: () => e.key))
            .toList());
  }

  Future<List<PengeluaranMdl>> getOperasionalOnly({
    required DateTime tgl,
  }) {
    var startTimestamp =
        Timestamp.fromDateTime(DateTime(tgl.year, tgl.month, tgl.day));
    var endTimestamp =
        Timestamp.fromDateTime(DateTime(tgl.year, tgl.month, tgl.day + 1));
    return storePengeluaran
        .query(
            finder: Finder(
                filter: Filter.and([
          Filter.greaterThanOrEquals('tanggal', startTimestamp),
          Filter.lessThan('tanggal', endTimestamp),
          Filter.equals('tipePengeluaran', 'operasional')
        ])))
        .getSnapshots(db)
        .then((value) => value
            .map((e) => PengeluaranMdl.fromJson(e.value).copyWith(
                  id: () => e.key,
                ))
            .toList());
  }

  @override
  Future<List<PengeluaranMdl>> getFiltered(
      {required DateTime tglStart, required DateTime tglEnd}) {
    var ts = (tglStart);
    var te = (tglEnd);

    var startTimestamp =
        Timestamp.fromDateTime(DateTime(ts.year, ts.month, ts.day));
    var endTimestamp =
        Timestamp.fromDateTime(DateTime(te.year, te.month, te.day));

    return storePengeluaran
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
            .map((e) =>
                PengeluaranMdl.fromJson(e.value).copyWith(id: () => e.key))
            .toList());
  }

  @override
  Future<int> insert(PengeluaranMdl data) async {
    try {
      var exist = await storePengeluaranNama
          .query(finder: Finder(filter: Filter.equals('nama', data)))
          .getSnapshots(db);
      if (exist.isEmpty) {
        await storePengeluaranNama.add(db, {'nama': data.namaPengeluaran});
      }
      // return 0;
      return await storePengeluaran.add(db, data.toJson());
    } catch (e) {
      return -1;
    }
  }

  void debug([String? data]) async {
    // storePengeluaranNama.drop(db);
    // var exist = await storePengeluaranNama
    //     .query(finder: Finder(filter: Filter.equals('', data)))
    //     .getSnapshots(db)
    //     .then((value) {
    //   print('element');
    //   print(value);
    //   return value.any((element) {
    //     return element.value == data;
    //   });
    // });
    var exist = await storePengeluaranNama
        // .query()
        .query(finder: Finder(filter: Filter.equals('nama', data)))
        .getSnapshots(db)
        .then((value) {
      return value.isNotEmpty;
    });
    if (!exist) {
      var a = await storePengeluaranNama.add(db, {'nama': data});
      // print(a);
    }
    print(exist);
    // print();
  }
}
