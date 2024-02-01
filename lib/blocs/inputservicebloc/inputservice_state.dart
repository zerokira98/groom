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
  final String? err;
  final String? success;
  InputserviceLoaded(
      {required this.karyawanName,
      required this.itemCards,
      this.err,
      this.success});

  InputserviceLoaded copyWith({
    String? karyawanName,
    List<ItemCardMdl>? itemCards,
    ValueGetter<String?>? err,
    ValueGetter<String?>? success,
  }) {
    return InputserviceLoaded(
      karyawanName: karyawanName ?? this.karyawanName,
      itemCards: itemCards ?? this.itemCards,
      err: err != null ? err() : this.err,
      success: success != null ? success() : this.success,
    );
  }

  @override
  List<Object?> get props => [karyawanName, itemCards, err, success];
}
