import 'package:json_annotation/json_annotation.dart';

import 'package:equatable/equatable.dart';

part 'bondata_mdl.g.dart';

@JsonSerializable()
class BonData extends Equatable {
  BonData(
      {required this.namaSubjek,
      required this.idKey,
      required this.jumlahBon,
      required this.tipe});

  final String namaSubjek;
  final int idKey;
  final String jumlahBon;
  final BonType tipe;
  BonData copyWith(
      {String? namaSubjek, int? idKey, String? jumlahBon, BonType? tipe}) {
    return BonData(
        namaSubjek: namaSubjek ?? this.namaSubjek,
        idKey: idKey ?? this.idKey,
        jumlahBon: jumlahBon ?? this.jumlahBon,
        tipe: tipe ?? this.tipe);
  }

  @override
  List<Object?> get props => [namaSubjek, idKey, jumlahBon, tipe];

  Map<String, dynamic> toJson() => _$BonDataToJson(this);

  factory BonData.fromJson(Map<String, dynamic> json) =>
      _$BonDataFromJson(json);
}

enum BonType { berhutang, bayarhutang }
