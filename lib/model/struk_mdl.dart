import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:groom/etc/timestamp_converter_firestore.dart';
import 'package:groom/model/pelanggan_mdl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:groom/model/itemcard_mdl.dart';

///  int? id;
///    String namaKaryawan;
///    DateTime tanggal;
///    List<ItemCardMdl> itemCards;
part 'struk_mdl.g.dart';

@JsonSerializable(explicitToJson: true)
class StrukMdl extends Equatable {
  final String? id;
  final String namaKaryawan;
  @TimestampConverterFirestore()
  final DateTime tanggal;
  final PelangganMdl? pelanggan;
  final TipePembayaran tipePembayaran;
  final List<ItemCardMdl> itemCards;

  const StrukMdl(
      {required this.namaKaryawan,
      required this.tanggal,
      required this.tipePembayaran,
      required this.itemCards,
      this.id,
      this.pelanggan});

  @override
  List<Object?> get props =>
      [id, namaKaryawan, tanggal, pelanggan, tipePembayaran, itemCards];

  StrukMdl copyWith(
      {ValueGetter<String?>? id,
      String? namaKaryawan,
      DateTime? tanggal,
      ValueGetter<PelangganMdl?>? pelanggan,
      TipePembayaran? tipePembayaran,
      List<ItemCardMdl>? itemCards}) {
    return StrukMdl(
        id: id != null ? id() : this.id,
        namaKaryawan: namaKaryawan ?? this.namaKaryawan,
        tanggal: tanggal ?? this.tanggal,
        pelanggan: pelanggan != null ? pelanggan() : this.pelanggan,
        tipePembayaran: tipePembayaran ?? this.tipePembayaran,
        itemCards: itemCards ?? this.itemCards);
  }

  Map<String, dynamic> toJson() => _$StrukMdlToJson(this);

  factory StrukMdl.fromJson(Map<String, dynamic> json) =>
      _$StrukMdlFromJson(json);
}

enum TipePembayaran { qris, cash }
