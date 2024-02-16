part of 'inputservice_bloc.dart';

@immutable
sealed class InputserviceState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class InputserviceInitial extends InputserviceState {
  @override
  List<Object?> get props => [];
}

final class InputserviceLoaded extends InputserviceState {
  final String karyawanName;
  final List<ItemCardMdl> itemCards;
  final DateTime tanggal;
  final TipePembayaran tipePembayaran;
  final String? err;
  final String? success;
  InputserviceLoaded(
      {required this.karyawanName,
      required this.itemCards,
      required this.tanggal,
      required this.tipePembayaran,
      this.err,
      this.success});

  InputserviceLoaded copyWith(
      {String? karyawanName,
      List<ItemCardMdl>? itemCards,
      DateTime? tanggal,
      TipePembayaran? tipePembayaran,
      ValueGetter<String?>? err,
      ValueGetter<String?>? success}) {
    return InputserviceLoaded(
        karyawanName: karyawanName ?? this.karyawanName,
        itemCards: itemCards ?? this.itemCards,
        tanggal: tanggal ?? this.tanggal,
        tipePembayaran: tipePembayaran ?? this.tipePembayaran,
        err: err != null ? err() : this.err,
        success: success != null ? success() : this.success);
  }

  @override
  List<Object?> get props =>
      [karyawanName, itemCards, tanggal, err, success, tipePembayaran];
}
