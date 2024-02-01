import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:groom/model/itemcard_mdl.dart';
import 'package:sembast/timestamp.dart';

///  int? id;
///    String namaKaryawan;
///    DateTime tanggal;
///    List<ItemCardMdl> itemCards;
part 'struk_mdl.g.dart';

@JsonSerializable(explicitToJson: true)
class StrukMdl extends Equatable {
  final int? id;
  final String namaKaryawan;
  @TimestampConverter()
  final DateTime tanggal;
  final List<ItemCardMdl> itemCards;

  const StrukMdl(
      {required this.namaKaryawan,
      required this.tanggal,
      required this.itemCards,
      this.id});

  @override
  List<Object?> get props => [id, namaKaryawan, tanggal, itemCards];

  StrukMdl copyWith(
      {ValueGetter<int?>? id,
      String? namaKaryawan,
      DateTime? tanggal,
      List<ItemCardMdl>? itemCards}) {
    return StrukMdl(
        id: id != null ? id() : this.id,
        namaKaryawan: namaKaryawan ?? this.namaKaryawan,
        tanggal: tanggal ?? this.tanggal,
        itemCards: itemCards ?? this.itemCards);
  }

  Map<String, dynamic> toJson() => _$StrukMdlToJson(this);

  factory StrukMdl.fromJson(Map<String, dynamic> json) =>
      _$StrukMdlFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDateTime();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDateTime(date);
}
