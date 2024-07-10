import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerRepo {
  CollectionReference ref;
  CustomerRepo({required this.firestore}) : ref = firestore.collection('cust');
  FirebaseFirestore firestore;

  ///No check is used, might [added] multiple times
  Future addCustDate(String phoneNumber, DateTime time) async {
    return ref.doc(phoneNumber)
      ..collection('date').add({'date': Timestamp.fromDate(time)})
      ..set(
          {'phoneNumber': phoneNumber, 'latestDate': Timestamp.fromDate(time)});
  }

  getCust([String? phoneNumber]) {
    if (phoneNumber == null) {
      return ref.get();
    } else {
      return ref.doc(phoneNumber).get();
    }
  }

  changeCustName(String phoneNumber, String name) async {
    return ref.doc(phoneNumber).set({'name': name});
  }

  changeCustAddress(String phoneNumber, String address) async {
    return ref.doc(phoneNumber).set({'address': address});
  }
}
