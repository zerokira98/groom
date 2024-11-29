import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serviceitems_mdl.g.dart';

@JsonSerializable()
class ServiceitemsMdl extends Equatable {
  final String title;
  final int type;
  final int price;
  final String? img;
  const ServiceitemsMdl(
      {required this.title, required this.type, required this.price, this.img});

  @override
  List<Object?> get props => [title, type, price, img];

  ServiceitemsMdl copyWith(
      {String? title, int? type, int? price, ValueGetter<String?>? img}) {
    return ServiceitemsMdl(
      title: title ?? this.title,
      type: type ?? this.type,
      price: price ?? this.price,
      img: img != null ? img() : this.img,
    );
  }

  Map<String, dynamic> toJson() => _$ServiceitemsMdlToJson(this);

  factory ServiceitemsMdl.fromJson(Map<String, dynamic> json) =>
      _$ServiceitemsMdlFromJson(json);
}
