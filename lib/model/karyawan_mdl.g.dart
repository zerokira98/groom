// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'karyawan_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KaryawanData _$KaryawanDataFromJson(Map<String, dynamic> json) => KaryawanData(
      id: json['id'] as int,
      namaKaryawan: json['namaKaryawan'] as String,
      aktif: json['aktif'] as bool,
    );

Map<String, dynamic> _$KaryawanDataToJson(KaryawanData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'namaKaryawan': instance.namaKaryawan,
      'aktif': instance.aktif,
    };
