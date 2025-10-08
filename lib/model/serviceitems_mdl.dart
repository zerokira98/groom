import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serviceitems_mdl.g.dart';

@JsonSerializable()
class ServiceitemsMdl extends Equatable {
  final int index;
  final String title;
  final int employeeCut;
  final String? id;
  final int price;
  final int pcs;
  final String? img;

  const ServiceitemsMdl({
    this.pcs = 1,
    this.index = 0,
    required this.title,
    this.id,
    required this.price,
    this.img,
    required this.employeeCut,
  });

  @override
  List<Object?> get props => [title, id, price, img, employeeCut, pcs, index];

  ServiceitemsMdl copyWith({
    String? title,
    ValueGetter<String?>? id,
    ValueGetter<int>? pcs,
    ValueGetter<int>? index,
    int? price,
    ValueGetter<String?>? img,
    ValueGetter<int>? employeeCut,
  }) {
    return ServiceitemsMdl(
      employeeCut: employeeCut != null ? employeeCut() : this.employeeCut,
      title: title ?? this.title,
      id: id != null ? id() : this.id,
      pcs: pcs != null ? pcs() : this.pcs,
      index: index != null ? index() : this.index,
      price: price ?? this.price,
      img: img != null ? img() : this.img,
    );
  }

  Map<String, dynamic> toJson() => _$ServiceitemsMdlToJson(this);

  factory ServiceitemsMdl.fromJson(Map<String, dynamic> json) =>
      _$ServiceitemsMdlFromJson(json);
}
