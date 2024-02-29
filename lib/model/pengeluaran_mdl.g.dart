// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengeluaran_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PengeluaranMdl _$PengeluaranMdlFromJson(Map<String, dynamic> json) =>
    PengeluaranMdl(
      tanggal: const TimestampConverterFirestore()
          .fromJson(json['tanggal'] as Timestamp),
      tanggalPost: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['tanggalPost'], const TimestampConverterFirestore().fromJson),
      namaPengeluaran: json['namaPengeluaran'] as String,
      tipePengeluaran:
          $enumDecode(_$TipePengeluaranEnumMap, json['tipePengeluaran']),
      pcs: json['pcs'] as num,
      biaya: json['biaya'] as num,
      id: json['id'] as String?,
      karyawan: json['karyawan'] as String?,
    );

Map<String, dynamic> _$PengeluaranMdlToJson(PengeluaranMdl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tanggal': const TimestampConverterFirestore().toJson(instance.tanggal),
      'tanggalPost': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.tanggalPost, const TimestampConverterFirestore().toJson),
      'namaPengeluaran': instance.namaPengeluaran,
      'tipePengeluaran': _$TipePengeluaranEnumMap[instance.tipePengeluaran]!,
      'karyawan': instance.karyawan,
      'pcs': instance.pcs,
      'biaya': instance.biaya,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

const _$TipePengeluaranEnumMap = {
  TipePengeluaran.gaji: 'gaji',
  TipePengeluaran.operasional: 'operasional',
  TipePengeluaran.barangjual: 'barangjual',
  TipePengeluaran.uang: 'uang',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
