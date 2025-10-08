import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:groom/model/serviceitems_mdl.dart';

class ServiceItemsRepository {
  late CollectionReference<ServiceitemsMdl> ref;
  late CollectionReference<Map<String, dynamic>> catRef;
  FirebaseFirestore firestore;
  ServiceItemsRepository(this.firestore)
    : ref = firestore
          .collection('serviceItems')
          .withConverter(
            fromFirestore: (snapshot, options) =>
                ServiceitemsMdl.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson(),
          ),
      catRef = firestore.collection('itemcategories');
  Future<List<ServiceitemsMdl>> getItems({Filter? filter}) async {
    if (filter != null) {
      return ref.where(filter).get().then((value) {
        print('here');

        return value.docs
            .map((e) => e.data())
            .toList()
            .sorted((a, b) => a.title.compareTo(b.title));
      });
    }
    return ref.get().then((value) {
      print('here');

      return value.docs
          .map((e) => e.data())
          .toList()
          .sorted((a, b) => a.title.compareTo(b.title));
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
    return await ref.doc(data.id).set(data);
    // .then((value) async => await value.docs[0].reference.set(data));
  }

  ///{'title','id','orderindex'}
  Future<List<QueryDocumentSnapshot<Map>>> getCategories({
    Filter? filter,
  }) async {
    if (filter != null) {
      return catRef.where(filter).get().then((value) => value.docs);
    }
    return catRef.orderBy('orderindex').get().then((value) => value.docs);
  }

  Future addCategory(Map<String, dynamic> data) async {
    bool exist = await catRef
        .where('title', isEqualTo: data['title'])
        .get()
        .then((value) => value.docs.isNotEmpty);
    if (exist) {
      throw Exception('title with same name already exist');
    }
    return (catRef.add(data), catRef.count().get()).wait.then((value) {
      return value.$1.update({'id': value.$1.id, 'sortindex': value.$2.count});
    });
  }

  Future editCategory(String title, String id) async {
    return catRef.doc(id).update({'title': title});
  }

  Future<void> updateOrder(String id, int newIndex) {
    return catRef.doc(id).update({'orderindex': newIndex});
  }

  Future<void> deleteCategory(String id) {
    return catRef.doc(id).delete();
  }
}
