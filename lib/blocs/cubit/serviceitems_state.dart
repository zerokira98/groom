// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'serviceitems_cubit.dart';

class ServiceitemsState extends Equatable {
  final List datas;
  final List<QueryDocumentSnapshot<Map>> categories;

  ///{'status','details'}
  final Map<String, dynamic>? msg;
  final Status status;
  const ServiceitemsState(
    this.datas,
    this.categories, {
    this.msg,
    this.status = Status.loaded,
  });
  static ServiceitemsState get initial => ServiceitemsState([], [],status: .loading);
  @override
  List<dynamic> get props => [datas, msg, categories];

  ServiceitemsState copyWith({
    List? datas,
    List<QueryDocumentSnapshot <Map>>?categories,
    Map<String, dynamic>? msg,
    Status? status,
  }) {
    return ServiceitemsState(
      datas ?? this.datas,
      categories ?? this.categories,
      msg: msg ?? this.msg,
      status: status ?? this.status,
    );
  }
}

enum Status { success, error, loading, loaded }
