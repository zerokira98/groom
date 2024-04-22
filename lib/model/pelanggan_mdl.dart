import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groom/etc/timestamp_converter_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
part 'pelanggan_mdl.g.dart';

@JsonSerializable()
class PelangganMdl {
  PelangganMdl(
      {required this.nama, required this.kontak, required this.dibuat});

  String nama;
  String kontak;

  @TimestampConverterFirestore()
  DateTime dibuat;
  Map<String, dynamic> toJson() => _$PelangganMdlToJson(this);

  factory PelangganMdl.fromJson(Map<String, dynamic> json) =>
      _$PelangganMdlFromJson(json);
  PelangganMdl copyWith({String? nama, String? kontak, DateTime? dibuat}) {
    return PelangganMdl(
        nama: nama ?? this.nama,
        kontak: kontak ?? this.kontak,
        dibuat: dibuat ?? this.dibuat);
  }
}
