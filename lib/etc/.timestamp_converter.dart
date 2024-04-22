import 'package:json_annotation/json_annotation.dart';

import 'package:sembast/timestamp.dart';

// @JsonSerializable()
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDateTime();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDateTime(date);
}
