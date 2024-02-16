part of 'pengeluaran_bloc.dart';

sealed class PengeluaranState extends Equatable {
  const PengeluaranState();
  
  @override
  List<Object> get props => [];
}

final class PengeluaranInitial extends PengeluaranState {}
