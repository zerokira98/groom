import 'package:flutter/material.dart';

import 'package:groom/etc/timestamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:equatable/equatable.dart';
import 'package:sembast/timestamp.dart';

part 'bondata_mdl.g.dart';

@JsonSerializable()
class BonData extends Equatable {
  const BonData(
      {required this.namaSubjek,
      required this.jumlahBon,
      required this.tipe,
      this.idKey,
      this.tanggal});

  final String namaSubjek;
  final int? idKey;
  @TimestampConverter()
  final DateTime? tanggal;
  final int jumlahBon;
  final BonType tipe;
  BonData copyWith(
      {String? namaSubjek,
      ValueGetter<int?>? idKey,
      ValueGetter<DateTime?>? tanggal,
      int? jumlahBon,
      BonType? tipe}) {
    return BonData(
        namaSubjek: namaSubjek ?? this.namaSubjek,
        idKey: idKey != null ? idKey() : this.idKey,
        tanggal: tanggal != null ? tanggal() : this.tanggal,
        jumlahBon: jumlahBon ?? this.jumlahBon,
        tipe: tipe ?? this.tipe);
  }

  @override
  List<Object?> get props => [namaSubjek, idKey, tanggal, jumlahBon, tipe];

  Map<String, dynamic> toJson() => _$BonDataToJson(this);

  factory BonData.fromJson(Map<String, dynamic> json) =>
      _$BonDataFromJson(json);
}

enum BonType { berhutang, bayarhutang }
