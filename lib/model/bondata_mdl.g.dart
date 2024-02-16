// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bondata_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BonData _$BonDataFromJson(Map<String, dynamic> json) => BonData(
      namaSubjek: json['namaSubjek'] as String,
      jumlahBon: json['jumlahBon'] as int,
      tipe: $enumDecode(_$BonTypeEnumMap, json['tipe']),
      idKey: json['idKey'] as int?,
      tanggal: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['tanggal'], const TimestampConverter().fromJson),
    );

Map<String, dynamic> _$BonDataToJson(BonData instance) => <String, dynamic>{
      'namaSubjek': instance.namaSubjek,
      'idKey': instance.idKey,
      'tanggal': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.tanggal, const TimestampConverter().toJson),
      'jumlahBon': instance.jumlahBon,
      'tipe': _$BonTypeEnumMap[instance.tipe]!,
    };

const _$BonTypeEnumMap = {
  BonType.berhutang: 'berhutang',
  BonType.bayarhutang: 'bayarhutang',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
