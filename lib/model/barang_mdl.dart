import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'barang_mdl.g.dart';

@JsonSerializable()
class BarangMdl extends Equatable {
  const BarangMdl(
      {required this.namaBarang,
      required this.pcs,
      required this.hargabeli,
      required this.hargajual,
      this.id,
      this.tglUpdate});

  final num? id;
  final DateTime? tglUpdate;
  final String namaBarang;
  final num pcs;
  final num hargabeli;
  final num hargajual;
  BarangMdl copyWith(
      {ValueGetter<num?>? id,
      ValueGetter<DateTime?>? tglUpdate,
      String? namaBarang,
      num? pcs,
      num? hargabeli,
      num? hargajual}) {
    return BarangMdl(
        id: id != null ? id() : this.id,
        tglUpdate: tglUpdate != null ? tglUpdate() : this.tglUpdate,
        namaBarang: namaBarang ?? this.namaBarang,
        pcs: pcs ?? this.pcs,
        hargabeli: hargabeli ?? this.hargabeli,
        hargajual: hargajual ?? this.hargajual);
  }

  @override
  String toString() {
    return 'BarangMdl{id=$id, tglUpdate=$tglUpdate, namaBarang=$namaBarang, pcs=$pcs, hargabeli=$hargabeli, hargajual=$hargajual}';
  }

  @override
  List<Object?> get props => [id, namaBarang, pcs, hargabeli, hargajual];
  Map<String, dynamic> toJson() => _$BarangMdlToJson(this);

  factory BarangMdl.fromJson(Map<String, dynamic> json) =>
      _$BarangMdlFromJson(json);
}
