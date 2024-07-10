part of 'bulanan_cubit.dart';

// sealed class BulananState extends Equatable {
//   const BulananState();

//   @override
//   List<Object> get props => [];
// }

final class BulananState extends Equatable {
  BulananState(
      {required this.pendapatanTertinggi,
      required this.jumlahCustomerTertinggi,
      required this.bulan,
      required this.groupAndSumPengeluaran,
      required this.totalPengeluaran,
      required this.totalPemasukan,
      required this.incomePerHari});

  final Map<String, num> pendapatanTertinggi;
  final Map<String, num> jumlahCustomerTertinggi;
  final DateTime bulan;
  final Map groupAndSumPengeluaran;
  final num totalPengeluaran;
  final num totalPemasukan;
  final List<num> incomePerHari;

  static BulananState initial() => BulananState(
        bulan: DateTime.now(),
        totalPengeluaran: 0,
        totalPemasukan: 0,
        incomePerHari: const [],
        groupAndSumPengeluaran: const {},
        pendapatanTertinggi: const {},
        jumlahCustomerTertinggi: const {},
      );

  @override
  List<Object?> get props => [
        pendapatanTertinggi,
        jumlahCustomerTertinggi,
        bulan,
        groupAndSumPengeluaran,
        totalPengeluaran,
        totalPemasukan,
        incomePerHari
      ];

  BulananState copyWith(
      {Map<String, num>? pendapatanTertinggi,
      Map<String, num>? jumlahCustomerTertinggi,
      DateTime? bulan,
      Map? groupAndSumPengeluaran,
      num? totalPengeluaran,
      num? totalPemasukan,
      List<num>? incomePerHari}) {
    return BulananState(
        pendapatanTertinggi: pendapatanTertinggi ?? this.pendapatanTertinggi,
        jumlahCustomerTertinggi:
            jumlahCustomerTertinggi ?? this.jumlahCustomerTertinggi,
        bulan: bulan ?? this.bulan,
        groupAndSumPengeluaran:
            groupAndSumPengeluaran ?? this.groupAndSumPengeluaran,
        totalPengeluaran: totalPengeluaran ?? this.totalPengeluaran,
        totalPemasukan: totalPemasukan ?? this.totalPemasukan,
        incomePerHari: incomePerHari ?? this.incomePerHari);
  }
}
