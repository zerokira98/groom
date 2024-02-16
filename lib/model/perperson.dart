import 'package:equatable/equatable.dart';
import 'package:groom/model/itemcard_mdl.dart';

class PerPerson extends Equatable {
  const PerPerson(
      {required this.namaKaryawan,
      required this.perCategory,
      required this.totalPendapatan});

  final String namaKaryawan;
  final List<ItemCardMdl> perCategory;
  final int totalPendapatan;

  @override
  List<Object?> get props => [namaKaryawan, perCategory, totalPendapatan];

  PerPerson copyWith(
      {String? namaKaryawan,
      List<ItemCardMdl>? perCategory,
      int? totalPendapatan}) {
    return PerPerson(
        namaKaryawan: namaKaryawan ?? this.namaKaryawan,
        perCategory: perCategory ?? this.perCategory,
        totalPendapatan: totalPendapatan ?? this.totalPendapatan);
  }
}
