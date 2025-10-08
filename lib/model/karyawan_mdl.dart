import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'karyawan_mdl.g.dart';

@JsonSerializable()
class KaryawanData extends Equatable {
  const KaryawanData({
    required this.namaKaryawan,
    required this.aktif,
    this.id,
    this.warnahex,
    this.password,
  });

  ///might not real id in db
  final String? id;
  final String namaKaryawan;
  final String? password;
  final String? warnahex;
  final bool aktif;
  KaryawanData copyWith({
    ValueGetter<String?>? id,
    String? namaKaryawan,
    ValueGetter<String?>? password,
    ValueGetter<String?>? warnahex,
    bool? aktif,
  }) {
    return KaryawanData(
      id: id != null ? id() : this.id,
      namaKaryawan: namaKaryawan ?? this.namaKaryawan,
      password: password != null ? password() : this.password,
      warnahex: warnahex != null ? warnahex() : this.warnahex,
      aktif: aktif ?? this.aktif,
    );
  }

  @override
  List<Object?> get props => [id, namaKaryawan, password, aktif, warnahex];

  Map<String, dynamic> toJson() => _$KaryawanDataToJson(this);

  factory KaryawanData.fromJson(Map<String, dynamic> json) =>
      _$KaryawanDataFromJson(json);
}
