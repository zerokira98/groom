import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serviceitems_mdl.g.dart';

@JsonSerializable()
class ServiceitemsMdl extends Equatable {
  final String title;
  final int type;
  final int price;
  const ServiceitemsMdl(
      {required this.title, required this.type, required this.price});

  @override
  List<Object?> get props => [title, type, price];

  ServiceitemsMdl copyWith({String? title, int? type, int? price}) {
    return ServiceitemsMdl(
        title: title ?? this.title,
        type: type ?? this.type,
        price: price ?? this.price);
  }

  Map<String, dynamic> toJson() => _$ServiceitemsMdlToJson(this);

  factory ServiceitemsMdl.fromJson(Map<String, dynamic> json) =>
      _$ServiceitemsMdlFromJson(json);
}
