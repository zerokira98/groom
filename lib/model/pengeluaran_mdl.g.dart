// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengeluaran_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PengeluaranMdl _$PengeluaranMdlFromJson(Map<String, dynamic> json) =>
    PengeluaranMdl(
      tanggal:
          const TimestampConverter().fromJson(json['tanggal'] as Timestamp),
      namaPengeluaran: json['namaPengeluaran'] as String,
      tipePengeluaran:
          $enumDecode(_$TipePengeluaranEnumMap, json['tipePengeluaran']),
      pcs: json['pcs'] as num,
      biaya: json['biaya'] as num,
      id: json['id'] as int?,
      karyawan: json['karyawan'] as String?,
    );

Map<String, dynamic> _$PengeluaranMdlToJson(PengeluaranMdl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tanggal': const TimestampConverter().toJson(instance.tanggal),
      'namaPengeluaran': instance.namaPengeluaran,
      'tipePengeluaran': _$TipePengeluaranEnumMap[instance.tipePengeluaran]!,
      'karyawan': instance.karyawan,
      'pcs': instance.pcs,
      'biaya': instance.biaya,
    };

const _$TipePengeluaranEnumMap = {
  TipePengeluaran.gaji: 'gaji',
  TipePengeluaran.operasional: 'operasional',
  TipePengeluaran.barangjual: 'barangjual',
  TipePengeluaran.dividen: 'dividen',
};
