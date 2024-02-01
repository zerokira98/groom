import 'package:equatable/equatable.dart';

class PerPerson extends Equatable {
  const PerPerson({required this.namaKaryawan, required this.totalPendapatan});

  final String namaKaryawan;
  final int totalPendapatan;

  @override
  List<Object?> get props => [namaKaryawan, totalPendapatan];
  PerPerson copyWith({String? namaKaryawan, int? totalPendapatan}) {
    return PerPerson(
        namaKaryawan: namaKaryawan ?? this.namaKaryawan,
        totalPendapatan: totalPendapatan ?? this.totalPendapatan);
  }
}
