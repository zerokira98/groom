part of 'rangkumanharian_cubit.dart';

sealed class RangkumanDayState extends Equatable {
  const RangkumanDayState();

  @override
  List<Object?> get props => [];
}

final class RangkumanDayInitial extends RangkumanDayState {}

final class RangkumanDayLoaded extends RangkumanDayState {
  final DateTime tanggalStart;
  final DateTime tanggalEnd;
  final List<PerPerson> incomePerPerson;
  final List<PengeluaranMdl> pengeluaranList;
  final num qristotal;
  final num operasional;
  final num bontotal;
  const RangkumanDayLoaded(
      {required this.tanggalStart,
      required this.tanggalEnd,
      required this.incomePerPerson,
      required this.pengeluaranList,
      required this.qristotal,
      required this.operasional,
      required this.bontotal});

  @override
  List<Object?> get props => [
        tanggalStart,
        tanggalEnd,
        incomePerPerson,
        pengeluaranList,
        qristotal,
        operasional,
        bontotal
      ];

  RangkumanDayLoaded copyWith(
      {DateTime? tanggalStart,
      DateTime? tanggalEnd,
      List<PerPerson>? incomePerPerson,
      List<PengeluaranMdl>? pengeluaranList,
      num? qristotal,
      num? operasional,
      num? bontotal}) {
    return RangkumanDayLoaded(
        tanggalStart: tanggalStart ?? this.tanggalStart,
        tanggalEnd: tanggalEnd ?? this.tanggalEnd,
        incomePerPerson: incomePerPerson ?? this.incomePerPerson,
        pengeluaranList: pengeluaranList ?? this.pengeluaranList,
        qristotal: qristotal ?? this.qristotal,
        operasional: operasional ?? this.operasional,
        bontotal: bontotal ?? this.bontotal);
  }
}
