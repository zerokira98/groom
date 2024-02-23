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
