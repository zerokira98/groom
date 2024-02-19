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
  final num qristotal;
  final num operasional;
  RangkumanDayLoaded(
      {required this.tanggalStart,
      required this.tanggalEnd,
      required this.incomePerPerson,
      required this.qristotal,
      required this.operasional});

  @override
  List<Object?> get props =>
      [tanggalStart, tanggalEnd, incomePerPerson, qristotal, operasional];

  RangkumanDayLoaded copyWith(
      {DateTime? tanggalStart,
      DateTime? tanggalEnd,
      List<PerPerson>? incomePerPerson,
      num? qristotal,
      num? operasional}) {
    return RangkumanDayLoaded(
        tanggalStart: tanggalStart ?? this.tanggalStart,
        tanggalEnd: tanggalEnd ?? this.tanggalEnd,
        incomePerPerson: incomePerPerson ?? this.incomePerPerson,
        qristotal: qristotal ?? this.qristotal,
        operasional: operasional ?? this.operasional);
  }
}