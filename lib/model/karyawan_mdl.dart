import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'karyawan_mdl.g.dart';

@JsonSerializable()
class KaryawanData extends Equatable {
  const KaryawanData(
      {required this.id, required this.namaKaryawan, required this.aktif});

  ///might not real id in db
  final int id;
  final String namaKaryawan;
  final bool aktif;
  KaryawanData copyWith({int? id, String? namaKaryawan, bool? aktif}) {
    return KaryawanData(
        id: id ?? this.id,
        namaKaryawan: namaKaryawan ?? this.namaKaryawan,
        aktif: aktif ?? this.aktif);
  }

  @override
  List<Object?> get props => [id, namaKaryawan, aktif];
  Map<String, dynamic> toJson() => _$KaryawanDataToJson(this);

  factory KaryawanData.fromJson(Map<String, dynamic> json) =>
      _$KaryawanDataFromJson(json);
}
