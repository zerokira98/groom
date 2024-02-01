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

  const RangkumanDayLoaded(
      {required this.tanggalStart,
      required this.tanggalEnd,
      required this.incomePerPerson});

  @override
  List<Object?> get props => [tanggalStart, tanggalEnd, incomePerPerson];
  RangkumanDayLoaded copyWith(
      {DateTime? tanggalStart,
      DateTime? tanggalEnd,
      List<PerPerson>? incomePerPerson}) {
    return RangkumanDayLoaded(
        tanggalStart: tanggalStart ?? this.tanggalStart,
        tanggalEnd: tanggalEnd ?? this.tanggalEnd,
        incomePerPerson: incomePerPerson ?? this.incomePerPerson);
  }
}
