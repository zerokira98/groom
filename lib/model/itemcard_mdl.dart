import 'package:formz/formz.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'itemcard_mdl.g.dart';

@JsonSerializable()
class ItemCardMdl extends Equatable with FormzMixin {
  final int index;
  final int type;
  final int pcsBarang;
  final String namaBarang;
  final int price;
  const ItemCardMdl(
      {required this.index,
      required this.type,
      int? pcsBarang,
      String? namaBarang,
      required this.price})
      : namaBarang = namaBarang ?? '',
        pcsBarang = pcsBarang ?? 1;

  @override
  List<Object?> get props => [index, type, price, pcsBarang, namaBarang];

  ItemCardMdl copyWith(
      {int? index, int? type, int? pcsBarang, String? namaBarang, int? price}) {
    return ItemCardMdl(
        index: index ?? this.index,
        type: type ?? this.type,
        pcsBarang: pcsBarang ?? this.pcsBarang,
        namaBarang: namaBarang ?? this.namaBarang,
        price: price ?? this.price);
  }

  Map<String, dynamic> toJson() => _$ItemCardMdlToJson(this);

  factory ItemCardMdl.fromJson(Map<String, dynamic> json) =>
      _$ItemCardMdlFromJson(json);

  @override
  String toString() {
    return 'ItemCardMdl{index=$index, type=$type, pcsBarang=$pcsBarang, namaBarang=$namaBarang, price=$price}';
  }

  @override
  List<FormzInput> get inputs => [];
}

List cardType = [
  'Haircut(rambut)',
  'Shave(kumis,jenggot)',
  'Semir',
  'Barang',
  'Lainnya'
];
