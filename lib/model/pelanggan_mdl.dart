import 'package:groom/etc/timestamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sembast/timestamp.dart';
part 'pelanggan_mdl.g.dart';

@JsonSerializable()
class PelangganMdl {
  PelangganMdl(
      {required this.nama, required this.kontak, required this.dibuat});

  String nama;
  String kontak;

  @TimestampConverter()
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
