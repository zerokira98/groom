// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'struk_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StrukMdl _$StrukMdlFromJson(Map<String, dynamic> json) => StrukMdl(
      namaKaryawan: json['namaKaryawan'] as String,
      tanggal:
          const TimestampConverter().fromJson(json['tanggal'] as Timestamp),
      tipePembayaran:
          $enumDecode(_$TipePembayaranEnumMap, json['tipePembayaran']),
      itemCards: (json['itemCards'] as List<dynamic>)
          .map((e) => ItemCardMdl.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as int?,
      pelanggan: json['pelanggan'] == null
          ? null
          : PelangganMdl.fromJson(json['pelanggan'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StrukMdlToJson(StrukMdl instance) => <String, dynamic>{
      'id': instance.id,
      'namaKaryawan': instance.namaKaryawan,
      'tanggal': const TimestampConverter().toJson(instance.tanggal),
      'pelanggan': instance.pelanggan?.toJson(),
      'tipePembayaran': _$TipePembayaranEnumMap[instance.tipePembayaran]!,
      'itemCards': instance.itemCards.map((e) => e.toJson()).toList(),
    };

const _$TipePembayaranEnumMap = {
  TipePembayaran.qris: 'qris',
  TipePembayaran.cash: 'cash',
};
