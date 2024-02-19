part of 'DBservice.dart';

abstract class _BonRepo {
  Database db;
  _BonRepo(this.db);

  //////----- Bon data -----
  ///
  Future<List<BonData>> getAllBon();
  Future<List<BonData>> getBonFiltered(Filter filter);
  Future<int> addBon(BonData data);
  Future<int> deleteBon(BonData data);

  ///----- end karyawan -----
}

class BonRepository implements _BonRepo {
  StoreRef<int, Map<String, Object?>> storeBon =
      intMapStoreFactory.store('bonData');
  BonRepository({required this.db});
  @override
  Database db;

  @override
  Future<int> addBon(BonData data) {
    return storeBon.add(db, data.toJson());
  }

  @override
  Future<int> deleteBon(BonData data) {
    return storeBon.delete(db, finder: Finder(filter: Filter.byKey(100990)));
  }

  @override
  Future<List<BonData>> getAllBon() async {
    return storeBon.query().getSnapshots(db).then((value) => value
        .map((e) => BonData.fromJson(e.value).copyWith(idKey: () => e.key))
        .toList());
  }

  Future<List<BonData>> getByNama(
      {required String nama, DateTime? tgl, DateTime? tglEnd}) async {
    var fil = [Filter.equals('namaSubjek', nama)];
    if (tgl != null && tglEnd == null) {
      var sd = Timestamp.fromDateTime(DateUtils.dateOnly(tgl));
      var ed = Timestamp.fromDateTime(
          DateUtils.dateOnly(tgl).add(Duration(days: 1)));
      fil.add(Filter.greaterThanOrEquals('tanggal', sd));
      fil.add(Filter.lessThan('tanggal', ed));
      fil.add(Filter.equals('tipe', 'berhutang'));
    }
    if (tgl != null && tglEnd != null) {
      var sd = Timestamp.fromDateTime(DateUtils.dateOnly(tgl));
      var ed = Timestamp.fromDateTime(
          DateUtils.dateOnly(tglEnd).add(Duration(days: 1)));
      fil.add(Filter.greaterThanOrEquals('tanggal', sd));
      fil.add(Filter.lessThan('tanggal', ed));
    }
    return storeBon
        .query(finder: Finder(filter: Filter.and(fil)))
        .getSnapshots(db)
        .then((value) => value
            .map((e) => BonData.fromJson(e.value).copyWith(
                  idKey: () => e.key,
                ))
            .toList());
  }

  @override
  Future<List<BonData>> getBonFiltered(Filter filter) {
    return storeBon.query(finder: Finder(filter: filter)).getSnapshots(db).then(
        (value) => value
            .map((e) => BonData.fromJson(e.value).copyWith(idKey: () => e.key))
            .toList());
  }
}
