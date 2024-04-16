part of 'bulanan_cubit.dart';

// sealed class BulananState extends Equatable {
//   const BulananState();

//   @override
//   List<Object> get props => [];
// }

final class BulananState extends Equatable {
  const BulananState(
      {required this.totalPengeluaran,
      required this.totalPemasukan,
      required this.incomePerHari,
      required this.groupAndSumPengeluaran,
      required this.pendapatanTertinggi,
      required this.jumlahCustomerTertinggi});
  final Map<String, num> pendapatanTertinggi;
  final Map<String, num> jumlahCustomerTertinggi;
  final Map groupAndSumPengeluaran;
  final num totalPengeluaran;
  final num totalPemasukan;
  final List<num> incomePerHari;

  static BulananState initial() => const BulananState(
        totalPengeluaran: 0,
        totalPemasukan: 0,
        incomePerHari: [],
        groupAndSumPengeluaran: {},
        pendapatanTertinggi: {},
        jumlahCustomerTertinggi: {},
      );

  @override
  List<Object> get props => [
        totalPengeluaran,
        totalPemasukan,
        incomePerHari,
        groupAndSumPengeluaran,
        pendapatanTertinggi,
        jumlahCustomerTertinggi
      ];
}
