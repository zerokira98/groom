part of 'rangkumanmingg_cubit.dart';

sealed class RangkumanWeekState extends Equatable {
  const RangkumanWeekState();

  @override
  List<Object?> get props => [];
}

final class RangkumanWeekInitial extends RangkumanWeekState {}

final class RangkumanWeekLoaded extends RangkumanWeekState {
  final DateTime tanggalStart;
  final DateTime tanggalEnd;
  final GroupBy groupBy;
  final List<StrukMdl> dataPerPerson;
  // final RangkumFilter filter;
  final List<List<PerPerson>> daily;
  final int totalKotor;
  final int totalBagiHasil;
  final num pengeluaran;
  final num bon;

  RangkumanWeekLoaded(
      {required this.tanggalStart,
      required this.tanggalEnd,
      required this.groupBy,
      required this.dataPerPerson,
      required this.daily,
      required this.totalKotor,
      required this.totalBagiHasil,
      required this.pengeluaran,
      required this.bon});

  @override
  List<Object?> get props => [
        tanggalStart,
        tanggalEnd,
        groupBy,
        dataPerPerson,
        daily,
        totalKotor,
        totalBagiHasil,
        pengeluaran,
        bon
      ];

  RangkumanWeekLoaded copyWith(
      {DateTime? tanggalStart,
      DateTime? tanggalEnd,
      GroupBy? groupBy,
      List<StrukMdl>? dataPerPerson,
      List<List<PerPerson>>? daily,
      int? totalKotor,
      int? totalBagiHasil,
      num? pengeluaran,
      num? bon}) {
    return RangkumanWeekLoaded(
        tanggalStart: tanggalStart ?? this.tanggalStart,
        tanggalEnd: tanggalEnd ?? this.tanggalEnd,
        groupBy: groupBy ?? this.groupBy,
        dataPerPerson: dataPerPerson ?? this.dataPerPerson,
        daily: daily ?? this.daily,
        totalKotor: totalKotor ?? this.totalKotor,
        totalBagiHasil: totalBagiHasil ?? this.totalBagiHasil,
        pengeluaran: pengeluaran ?? this.pengeluaran,
        bon: bon ?? this.bon);
  }
}

enum GroupBy { namaKayrawan, date }
