// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemcard_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemCardMdl _$ItemCardMdlFromJson(Map<String, dynamic> json) => ItemCardMdl(
      index: json['index'] as int,
      type: json['type'] as int,
      pcsBarang: json['pcsBarang'] as int?,
      namaBarang: json['namaBarang'] as String?,
      price: json['price'] as int,
    );

Map<String, dynamic> _$ItemCardMdlToJson(ItemCardMdl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'type': instance.type,
      'pcsBarang': instance.pcsBarang,
      'namaBarang': instance.namaBarang,
      'price': instance.price,
    };
