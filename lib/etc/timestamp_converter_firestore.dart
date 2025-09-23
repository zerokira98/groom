import 'package:json_annotation/json_annotation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

// @JsonSerializable()
class TimestampConverterFirestore
    implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverterFirestore();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

// class DocumentIdConverterFirestore
//     implements JsonConverter<String?, String?> {
//   const DocumentIdConverterFirestore();

//   @override
//   String? fromJson(String? timestamp) {
//     return timestamp.toDate();
//   }

//   @override
//   String? toJson(String? originnull) => Timestamp.fromDate(date);
// }
