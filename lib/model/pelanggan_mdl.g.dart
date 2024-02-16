// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pelanggan_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PelangganMdl _$PelangganMdlFromJson(Map<String, dynamic> json) => PelangganMdl(
      nama: json['nama'] as String,
      kontak: json['kontak'] as String,
      dibuat: const TimestampConverter().fromJson(json['dibuat'] as Timestamp),
    );

Map<String, dynamic> _$PelangganMdlToJson(PelangganMdl instance) =>
    <String, dynamic>{
      'nama': instance.nama,
      'kontak': instance.kontak,
      'dibuat': const TimestampConverter().toJson(instance.dibuat),
    };
