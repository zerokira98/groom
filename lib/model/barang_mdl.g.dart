// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barang_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarangMdl _$BarangMdlFromJson(Map<String, dynamic> json) => BarangMdl(
      namaBarang: json['namaBarang'] as String,
      pcs: json['pcs'] as num,
      hargabeli: json['hargabeli'] as num,
      hargajual: json['hargajual'] as num,
      id: json['id'] as num?,
      tglUpdate: json['tglUpdate'] == null
          ? null
          : DateTime.parse(json['tglUpdate'] as String),
    );

Map<String, dynamic> _$BarangMdlToJson(BarangMdl instance) => <String, dynamic>{
      'id': instance.id,
      'tglUpdate': instance.tglUpdate?.toIso8601String(),
      'namaBarang': instance.namaBarang,
      'pcs': instance.pcs,
      'hargabeli': instance.hargabeli,
      'hargajual': instance.hargajual,
    };
