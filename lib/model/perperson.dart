import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:groom/model/itemcard_mdl.dart';
import 'package:groom/model/struk_mdl.dart';

class PerPerson extends Equatable {
  const PerPerson(
      {required this.namaKaryawan,
      required this.perCategory,
      required this.totalPendapatan,
      this.datas});

  final String namaKaryawan;
  final List<ItemCardMdl> perCategory;
  final int totalPendapatan;
  final List<StrukMdl>? datas;

  @override
  List<Object?> get props =>
      [namaKaryawan, perCategory, totalPendapatan, datas];

  PerPerson copyWith(
      {String? namaKaryawan,
      List<ItemCardMdl>? perCategory,
      int? totalPendapatan,
      ValueGetter<List<StrukMdl>?>? datas}) {
    return PerPerson(
        namaKaryawan: namaKaryawan ?? this.namaKaryawan,
        perCategory: perCategory ?? this.perCategory,
        totalPendapatan: totalPendapatan ?? this.totalPendapatan,
        datas: datas != null ? datas() : this.datas);
  }

  @override
  String toString() {
    return 'PerPerson{namaKaryawan=$namaKaryawan, perCategory=$perCategory, totalPendapatan=$totalPendapatan, datas=$datas}';
  }
}
