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
  final List<Map<DateTime, List<PerPerson>>> daily;
  final int totalKotor;
  final int totalBagiHasil;

  const RangkumanWeekLoaded(
      {required this.tanggalStart,
      required this.tanggalEnd,
      required this.groupBy,
      required this.dataPerPerson,
      required this.daily,
      required this.totalKotor,
      required this.totalBagiHasil});

  @override
  List<Object?> get props => [
        tanggalStart,
        tanggalEnd,
        groupBy,
        dataPerPerson,
        daily,
        totalKotor,
        totalBagiHasil
      ];

  RangkumanWeekLoaded copyWith(
      {DateTime? tanggalStart,
      DateTime? tanggalEnd,
      GroupBy? groupBy,
      List<StrukMdl>? dataPerPerson,
      List<Map<DateTime, List<PerPerson>>>? daily,
      int? totalKotor,
      int? totalBagiHasil}) {
    return RangkumanWeekLoaded(
        tanggalStart: tanggalStart ?? this.tanggalStart,
        tanggalEnd: tanggalEnd ?? this.tanggalEnd,
        groupBy: groupBy ?? this.groupBy,
        dataPerPerson: dataPerPerson ?? this.dataPerPerson,
        daily: daily ?? this.daily,
        totalKotor: totalKotor ?? this.totalKotor,
        totalBagiHasil: totalBagiHasil ?? this.totalBagiHasil);
  }
}

enum GroupBy { namaKayrawan, date }
