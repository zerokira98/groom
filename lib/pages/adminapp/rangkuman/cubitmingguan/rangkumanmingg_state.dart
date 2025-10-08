part of 'rangkumanmingg_cubit.dart';

sealed class RangkumanWeekState extends Equatable {
  const RangkumanWeekState();

  @override
  List<Object?> get props => [];
}

final class RangkumanWeekInitial extends RangkumanWeekState {}

final class RangkumanWeekLoaded extends RangkumanWeekState {
  final Datafilter filter;
  final GroupBy groupBy;
  final List<StrukMdl> dataPerPerson;
  // final RangkumFilter filter;
  final List<List<PerPerson>> daily;
  final Map pengeluaranlist;
  final int totalKotor;
  final int totalBagiHasil;
  final num pengeluaran;
  final num bon;
  final List<List<PerPerson>> dailycut;

  const RangkumanWeekLoaded({
    required this.filter,
    required this.groupBy,
    required this.dataPerPerson,
    required this.daily,
    required this.pengeluaranlist,
    required this.totalKotor,
    required this.totalBagiHasil,
    required this.pengeluaran,
    required this.bon,
    required this.dailycut,
  });

  @override
  List<Object?> get props => [
    filter,
    groupBy,
    dataPerPerson,
    daily,
    pengeluaranlist,
    totalKotor,
    totalBagiHasil,
    pengeluaran,
    bon,
    dailycut,
  ];

  RangkumanWeekLoaded copyWith({
    Datafilter? filter,
    GroupBy? groupBy,
    List<StrukMdl>? dataPerPerson,
    List<List<PerPerson>>? daily,
    Map? pengeluaranlist,
    int? totalKotor,
    int? totalBagiHasil,
    num? pengeluaran,
    num? bon,
    List<List<PerPerson>>? dailycut,
  }) {
    return RangkumanWeekLoaded(
      filter: filter ?? this.filter,
      groupBy: groupBy ?? this.groupBy,
      dataPerPerson: dataPerPerson ?? this.dataPerPerson,
      daily: daily ?? this.daily,
      pengeluaranlist: pengeluaranlist ?? this.pengeluaranlist,
      totalKotor: totalKotor ?? this.totalKotor,
      totalBagiHasil: totalBagiHasil ?? this.totalBagiHasil,
      pengeluaran: pengeluaran ?? this.pengeluaran,
      bon: bon ?? this.bon,
      dailycut: dailycut ?? this.dailycut,
    );
  }
}

enum GroupBy { namaKayrawan, date }
