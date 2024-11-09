part of 'inputservice_bloc.dart';

@immutable
sealed class InputserviceEvent {}

class Initiate extends InputserviceEvent {}

class AddCard extends InputserviceEvent {
  final int? type;

  AddCard({this.type});
}

class RemoveCard extends InputserviceEvent {
  final ItemCardMdl data;
  RemoveCard(this.data);
}

class SubmitToDB extends InputserviceEvent {
  SubmitToDB();
}

class ChangeItemType extends InputserviceEvent {
  final int idx;
  final int type;
  ChangeItemType({required this.idx, required this.type});
}

class ChangeTipePembayaran extends InputserviceEvent {
  final TipePembayaran type;
  ChangeTipePembayaran({required this.type});
}

class ChangeItemDetails extends InputserviceEvent {
  final int idx;
  final ItemCardMdl data;
  ChangeItemDetails({required this.idx, required this.data});
}

class ChangePrice extends InputserviceEvent {
  final int idx;
  final int price;
  ChangePrice({required this.idx, required this.price});
}

class ChangeKaryawan extends InputserviceEvent {
  final String karyawanName;
  ChangeKaryawan(this.karyawanName);
}

class ChangeTanggal extends InputserviceEvent {
  final DateTime tanggal;
  ChangeTanggal(this.tanggal);
}
