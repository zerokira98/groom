part of 'DBservice.dart';

abstract class _EkuitasRepo {
  Database db;
  _EkuitasRepo(this.db);
  var store = intMapStoreFactory.store('ekuitas');

  ///
  Future<List<EkuitasMdl>> getAll();
  Future<List<EkuitasMdl>> getFiltered(Filter filter);
  Future<int> add(EkuitasMdl data);
  Future<int> delete(EkuitasMdl data);
}

class EkuitasRepository extends _EkuitasRepo {
  EkuitasRepository(super.db);

  @override
  Future<int> add(EkuitasMdl data) async {
    return await store.add(db, data.toJson());
  }

  @override
  Future<int> delete(EkuitasMdl data) {
    return store.delete(db,
        finder: Finder(filter: Filter.equals('id', data.id)));
  }

  @override
  Future<List<EkuitasMdl>> getAll() {
    return store.query().getSnapshots(db).then((value) => value
        .map((e) => EkuitasMdl.fromJson(e.value).copyWith(id: () => e.key))
        .toList());
  }

  @override
  Future<List<EkuitasMdl>> getFiltered(Filter filter) {
    throw UnimplementedError();
  }
}
