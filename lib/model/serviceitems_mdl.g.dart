// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serviceitems_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceitemsMdl _$ServiceitemsMdlFromJson(Map<String, dynamic> json) =>
    ServiceitemsMdl(
      title: json['title'] as String,
      type: (json['type'] as num).toInt(),
      price: (json['price'] as num).toInt(),
    );

Map<String, dynamic> _$ServiceitemsMdlToJson(ServiceitemsMdl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'type': instance.type,
      'price': instance.price,
    };
