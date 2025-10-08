// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Datafilter {
  DateTime start;
  DateTime end;
  String sortfield;
  SortType sortType;
  Datafilter({
    required this.start,
    required this.end,
    required this.sortfield,
    required this.sortType,
  });

  Datafilter copyWith({
    DateTime? start,
    DateTime? end,
    String? sortfield,
    SortType? sortType,
  }) {
    return Datafilter(
      start: start ?? this.start,
      end: end ?? this.end,
      sortfield: sortfield ?? this.sortfield,
      sortType: sortType ?? this.sortType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'sortfield': sortfield,
      'sortType': sortType.name,
    };
  }

  factory Datafilter.fromMap(Map<String, dynamic> map) {
    return Datafilter(
      start: DateTime.fromMillisecondsSinceEpoch(map['start'] as int),
      end: DateTime.fromMillisecondsSinceEpoch(map['end'] as int),
      sortfield: map['sortfield'] as String,
      sortType: SortType.values.singleWhere(
        (element) => element.name == (map['sortType'] as String),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Datafilter.fromJson(String source) =>
      Datafilter.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Datafilter(start: $start, end: $end, sortfield: $sortfield, sortType: $sortType)';
  }

  @override
  bool operator ==(covariant Datafilter other) {
    if (identical(this, other)) return true;

    return other.start == start &&
        other.end == end &&
        other.sortfield == sortfield &&
        other.sortType == sortType;
  }

  @override
  int get hashCode {
    return start.hashCode ^
        end.hashCode ^
        sortfield.hashCode ^
        sortType.hashCode;
  }
}

enum SortType { asc, dsc, none }
