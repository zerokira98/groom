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
      required this.incomePerHari});
  final num totalPengeluaran;
  final num totalPemasukan;
  final List<num> incomePerHari;

  static BulananState initial() => const BulananState(
      totalPengeluaran: 0, totalPemasukan: 0, incomePerHari: []);

  @override
  List<Object> get props => [totalPengeluaran, totalPemasukan, incomePerHari];
}
