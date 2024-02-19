import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:groom/etc/timestamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sembast/timestamp.dart';
part 'ekuitas_mdl.g.dart';

@JsonSerializable()
class EkuitasMdl extends Equatable {
  const EkuitasMdl(
      {required this.tanggal,
      required this.uang,
      required this.deskripsi,
      this.id});

  final int? id;
  @TimestampConverter()
  final DateTime tanggal;
  final num uang;
  final String deskripsi;

  @override
  List<Object?> get props => [id, tanggal, uang, deskripsi];

  Map<String, dynamic> toJson() => _$EkuitasMdlToJson(this);

  factory EkuitasMdl.fromJson(Map<String, dynamic> json) =>
      _$EkuitasMdlFromJson(json);
  EkuitasMdl copyWith(
      {ValueGetter<int?>? id,
      DateTime? tanggal,
      num? uang,
      String? deskripsi}) {
    return EkuitasMdl(
        id: id != null ? id() : this.id,
        tanggal: tanggal ?? this.tanggal,
        uang: uang ?? this.uang,
        deskripsi: deskripsi ?? this.deskripsi);
  }
}
