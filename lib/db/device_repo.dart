import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groom/etc/globalvar.dart';

class DeviceRepo {
  CollectionReference ref;
  DeviceRepo({required this.firestore}) : ref = firestore.collection('devices');
  FirebaseFirestore firestore;
  updateToken(String deviceId, String token) {
    var datenow = Timestamp.fromDate(DateTime.now());
    ref
        .doc(deviceId)
        .set({'token': token, "timestamp": datenow, "admin": adminonly});
  }
}
