import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groom/model/serviceitems_mdl.dart';

class ServiceItemsRepository {
  late CollectionReference<ServiceitemsMdl> ref;
  FirebaseFirestore firestore;
  ServiceItemsRepository(this.firestore)
    : ref = firestore
          .collection('serviceItems')
          .withConverter(
            fromFirestore: (snapshot, options) =>
                ServiceitemsMdl.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson(),
          );
  Future<List<ServiceitemsMdl>> getItems() async {
    return ref.get().then((value) {
      print('here');

      return value.docs.map((e) => e.data()).toList();
    });
  }

  Future addItem(ServiceitemsMdl data) async {
    return ref.add(data).then((value) {
      return value.update({'id': value.id});
    });
  }

  Future deleteItem(ServiceitemsMdl data) async {
    return await ref
        .where('id', isEqualTo: data.id)
        .get()
        .then(
          (value) async =>
              await value.docs[0].reference.update({'deleted': true}),
        );
  }

  Future editItem(ServiceitemsMdl data) async {
    return await ref
        .where('id', isEqualTo: data.id)
        .get()
        .then((value) async => await value.docs[0].reference.set(data));
  }
}
