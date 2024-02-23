// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ekuitas_mdl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EkuitasMdl _$EkuitasMdlFromJson(Map<String, dynamic> json) => EkuitasMdl(
      tanggal: const TimestampConverterFirestore()
          .fromJson(json['tanggal'] as Timestamp),
      uang: json['uang'] as num,
      deskripsi: json['deskripsi'] as String,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$EkuitasMdlToJson(EkuitasMdl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tanggal': const TimestampConverterFirestore().toJson(instance.tanggal),
      'uang': instance.uang,
      'deskripsi': instance.deskripsi,
    };
