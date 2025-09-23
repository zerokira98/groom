import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:groom/model/model.dart';

class PerPerson extends Equatable {
  const PerPerson({
    required this.namaKaryawan,
    required this.perCategory,
    required this.totalPendapatan,
    this.datas,
  });

  final String namaKaryawan;
  final List<ServiceitemsMdl> perCategory;
  final int totalPendapatan;
  final List<StrukMdl>? datas;

  @override
  List<Object?> get props => [
    namaKaryawan,
    perCategory,
    totalPendapatan,
    datas,
  ];

  PerPerson copyWith({
    String? namaKaryawan,
    List<ServiceitemsMdl>? perCategory,
    int? totalPendapatan,
    ValueGetter<List<StrukMdl>?>? datas,
  }) {
    return PerPerson(
      namaKaryawan: namaKaryawan ?? this.namaKaryawan,
      perCategory: perCategory ?? this.perCategory,
      totalPendapatan: totalPendapatan ?? this.totalPendapatan,
      datas: datas != null ? datas() : this.datas,
    );
  }

  @override
  String toString() {
    return 'PerPerson{namaKaryawan=$namaKaryawan, perCategory=$perCategory, totalPendapatan=$totalPendapatan, datas=$datas}';
  }
}
