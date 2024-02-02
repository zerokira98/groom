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
    );

Map<String, dynamic> _$BonDataToJson(BonData instance) => <String, dynamic>{
      'namaSubjek': instance.namaSubjek,
      'idKey': instance.idKey,
      'jumlahBon': instance.jumlahBon,
      'tipe': _$BonTypeEnumMap[instance.tipe]!,
    };

const _$BonTypeEnumMap = {
  BonType.berhutang: 'berhutang',
  BonType.bayarhutang: 'bayarhutang',
};
