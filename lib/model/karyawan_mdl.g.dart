// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'karyawan_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KaryawanData _$KaryawanDataFromJson(Map<String, dynamic> json) => KaryawanData(
      namaKaryawan: json['namaKaryawan'] as String,
      aktif: json['aktif'] as bool,
      id: json['id'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$KaryawanDataToJson(KaryawanData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'namaKaryawan': instance.namaKaryawan,
      'password': instance.password,
      'aktif': instance.aktif,
    };
