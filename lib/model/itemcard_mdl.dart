// import 'package:flutter/foundation.dart';
// import 'package:formz/formz.dart';
// import 'package:json_annotation/json_annotation.dart';
// import 'package:equatable/equatable.dart';

// part 'itemcard_mdl.g.dart';

// @JsonSerializable()
// class ItemCardMdl extends Equatable with FormzMixin {
//   final int index;
//   final String? id;
//   final int pcsBarang;
//   final String namaBarang;
//   final int price;
//   const ItemCardMdl({
//     required this.index,
//     this.id,
//     int? pcsBarang,
//     String? namaBarang,
//     required this.price,
//   }) : namaBarang = namaBarang ?? '',
//        pcsBarang = pcsBarang ?? 1;
//   static ItemCardMdl get empty =>
//       const ItemCardMdl(index: 0, price: 0, namaBarang: '', pcsBarang: 1);
//   @override
//   List<Object?> get props => [index, id, price, pcsBarang, namaBarang];

//   ItemCardMdl copyWith({
//     int? index,
//     ValueGetter<String>? id,
//     int? pcsBarang,
//     String? namaBarang,
//     int? price,
//   }) {
//     return ItemCardMdl(
//       index: index ?? this.index,
//       id: id != null ? id() : this.id,
//       pcsBarang: pcsBarang ?? this.pcs,
//       namaBarang: namaBarang ?? this.namaBarang,
//       price: price ?? this.price,
//     );
//   }

//   Map<String, dynamic> toJson() => _$ItemCardMdlToJson(this);

//   factory ItemCardMdl.fromJson(Map<String, dynamic> json) =>
//       _$ItemCardMdlFromJson(json);

//   @override
//   String toString() {
//     return 'ItemCardMdl{index=$index, type=$id, pcsBarang=$pcsBarang, namaBarang=$namaBarang, price=$price}';
//   }

//   @override
//   List<FormzInput> get inputs => [];
// }

// // List<String> cardType = [
// //   'Haircut (rambut)',
// //   'Shave (kumis,jenggot)',
// //   'Semir',
// //   'Barang',
// //   'Lainnya',
// // ];
