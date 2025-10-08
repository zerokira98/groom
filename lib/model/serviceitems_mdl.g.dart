// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serviceitems_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceitemsMdl _$ServiceitemsMdlFromJson(Map<String, dynamic> json) =>
    ServiceitemsMdl(
      pcs: (json['pcs'] as num?)?.toInt() ?? 1,
      index: (json['index'] as num?)?.toInt() ?? 0,
      title: json['title'] as String,
      id: json['id'] as String?,
      price: (json['price'] as num).toInt(),
      img: json['img'] as String?,
      employeeCut: (json['employeeCut'] as num).toInt(),
    );

Map<String, dynamic> _$ServiceitemsMdlToJson(ServiceitemsMdl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'title': instance.title,
      'employeeCut': instance.employeeCut,
      'id': instance.id,
      'price': instance.price,
      'pcs': instance.pcs,
      'img': instance.img,
    };
