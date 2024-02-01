// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bondata_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BonData _$BonDataFromJson(Map<String, dynamic> json) => BonData(
      namaKaryawan: json['namaKaryawan'] as String,
      idKey: json['idKey'] as int,
      jumlahBon: json['jumlahBon'] as String,
      tipe: $enumDecode(_$BonTypeEnumMap, json['tipe']),
    );

Map<String, dynamic> _$BonDataToJson(BonData instance) => <String, dynamic>{
      'namaKaryawan': instance.namaKaryawan,
      'idKey': instance.idKey,
      'jumlahBon': instance.jumlahBon,
      'tipe': _$BonTypeEnumMap[instance.tipe]!,
    };

const _$BonTypeEnumMap = {
  BonType.berhutang: 'berhutang',
  BonType.bayarhutang: 'bayarhutang',
};
