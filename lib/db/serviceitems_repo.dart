import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groom/model/serviceitems_mdl.dart';

class ServiceItemsRepository {
  late CollectionReference<ServiceitemsMdl> ref;
  FirebaseFirestore firestore;
  ServiceItemsRepository(this.firestore)
      : ref = firestore.collection('serviceItems').withConverter(
              fromFirestore: (snapshot, options) =>
                  ServiceitemsMdl.fromJson(snapshot.data()!),
              toFirestore: (value, options) => value.toJson(),
            );
  Future<List> getItems() async {
    var fetch = await ref
        .get()
        .then((value) => value.docs.map((e) => e.data()).toList());
    return fetch;
  }

  Future addItem(ServiceitemsMdl data) async {
    return await ref.add(data);
  }

  Future deleteItem(ServiceitemsMdl data) async {
    return await ref.where('type', isEqualTo: data.type).get().then(
          (value) async =>
              await value.docs[0].reference.update({'deleted': true}),
        );
  }

  Future editItem(ServiceitemsMdl data) async {
    return await ref.where('type', isEqualTo: data.type).get().then(
          (value) async => await value.docs[0].reference.set(data),
        );
  }
}
