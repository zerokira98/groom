import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:groom/etc/timestamp_converter_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:equatable/equatable.dart';

part 'bondata_mdl.g.dart';

@JsonSerializable()
class BonData extends Equatable {
  const BonData(
      {required this.namaSubjek,
      required this.jumlahBon,
      required this.tipe,
      this.idKey,
      this.tanggal,
      this.author});

  final String namaSubjek;
  final String? idKey;
  @TimestampConverterFirestore()
  final DateTime? tanggal;
  final int jumlahBon;
  final BonType tipe;
  final Author? author;
  BonData copyWith(
      {String? namaSubjek,
      ValueGetter<String?>? idKey,
      ValueGetter<DateTime?>? tanggal,
      int? jumlahBon,
      BonType? tipe,
      ValueGetter<Author?>? author}) {
    return BonData(
        namaSubjek: namaSubjek ?? this.namaSubjek,
        idKey: idKey != null ? idKey() : this.idKey,
        tanggal: tanggal != null ? tanggal() : this.tanggal,
        jumlahBon: jumlahBon ?? this.jumlahBon,
        tipe: tipe ?? this.tipe,
        author: author != null ? author() : this.author);
  }

  @override
  List<Object?> get props =>
      [namaSubjek, idKey, tanggal, jumlahBon, tipe, author];

  Map<String, dynamic> toJson() => _$BonDataToJson(this);

  factory BonData.fromJson(Map<String, dynamic> json) =>
      _$BonDataFromJson(json);
}

enum BonType { berhutang, bayarhutang }

enum Author { self, admin }
