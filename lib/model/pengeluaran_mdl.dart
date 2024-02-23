import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
// import 'package:groom/etc/timestamp_converter.dart';
import 'package:groom/etc/timestamp_converter_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
// import 'package:sembast/timestamp.dart';

part 'pengeluaran_mdl.g.dart';

@JsonSerializable()
class PengeluaranMdl extends Equatable {
  const PengeluaranMdl(
      {required this.tanggal,
      required this.namaPengeluaran,
      required this.tipePengeluaran,
      required this.pcs,
      required this.biaya,
      this.id,
      this.karyawan});

  final String? id;
  @TimestampConverterFirestore()
  final DateTime tanggal;
  final String namaPengeluaran;
  final TipePengeluaran tipePengeluaran;
  final String? karyawan;
  final num pcs;
  final num biaya;
  PengeluaranMdl copyWith(
      {ValueGetter<String?>? id,
      DateTime? tanggal,
      String? namaPengeluaran,
      TipePengeluaran? tipePengeluaran,
      ValueGetter<String?>? karyawan,
      num? pcs,
      num? biaya}) {
    return PengeluaranMdl(
        id: id != null ? id() : this.id,
        tanggal: tanggal ?? this.tanggal,
        namaPengeluaran: namaPengeluaran ?? this.namaPengeluaran,
        tipePengeluaran: tipePengeluaran ?? this.tipePengeluaran,
        karyawan: karyawan != null ? karyawan() : this.karyawan,
        pcs: pcs ?? this.pcs,
        biaya: biaya ?? this.biaya);
  }

  Map<String, dynamic> toJson() => _$PengeluaranMdlToJson(this);

  factory PengeluaranMdl.fromJson(Map<String, dynamic> json) =>
      _$PengeluaranMdlFromJson(json);

  @override
  List<Object?> get props =>
      [id, tanggal, namaPengeluaran, pcs, biaya, karyawan];

  @override
  String toString() {
    return 'PengeluaranMdl{id=$id, tanggal=$tanggal, namaPengeluaran=$namaPengeluaran, tipePengeluaran=$tipePengeluaran, pcs=$pcs, biaya=$biaya}';
  }
}

enum TipePengeluaran { gaji, operasional, barangjual, uang }
