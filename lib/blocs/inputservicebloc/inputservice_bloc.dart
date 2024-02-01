import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/model/itemcard_mdl.dart';
import 'package:groom/model/struk_mdl.dart';

part 'inputservice_event.dart';
part 'inputservice_state.dart';

class InputserviceBloc extends Bloc<InputserviceEvent, InputserviceState> {
  PemasukanRepository strukrepo;
  KaryawanRepository karyawanrepo;
  InputserviceBloc({required this.strukrepo, required this.karyawanrepo})
      : super(InputserviceInitial()) {
    on<Initiate>((event, emit) async {
      var a = await karyawanrepo.getAllKaryawan();
      emit(InputserviceLoaded(
          karyawanName: a.first.namaKaryawan, itemCards: const []));
    });
    on<SubmitToDB>((event, emit) async {
      var theState = (state as InputserviceLoaded);
      var a = StrukMdl(
          namaKaryawan: theState.karyawanName,
          tanggal: DateTime.now(),
          itemCards: theState.itemCards);
      print('here');
      try {
        var x = await strukrepo.insertStruk(a);
        print(x);
        emit(InputserviceLoaded(
            karyawanName: theState.karyawanName,
            itemCards: const [],
            success: 'input success'));
      } catch (e) {
        emit(theState.copyWith(err: () => e.toString()));
      }
    });
    on<ChangePrice>((event, emit) {
      if (state is InputserviceLoaded) {
        var theState = (state as InputserviceLoaded);

        emit(theState.copyWith(
            itemCards: theState.itemCards
                .map((e) =>
                    e.index == event.idx ? e.copyWith(price: event.price) : e)
                .toList()));
      }
    });
    on<ChangeItemDetails>((event, emit) {
      if (state is InputserviceLoaded) {
        var theState = (state as InputserviceLoaded);

        emit(theState.copyWith(
            itemCards: theState.itemCards
                .map((e) => e.index == event.idx ? event.data : e)
                .toList()));
      }
    });
    on<RemoveCard>((event, emit) {
      if (state is InputserviceLoaded) {
        var theState = (state as InputserviceLoaded);
        emit(theState.copyWith(
            itemCards:
                theState.itemCards.where((e) => e != event.data).toList()));
      }
    });
    on<AddCard>((event, emit) {
      if (state is InputserviceLoaded) {
        var theState = (state as InputserviceLoaded);
        var idx =
            theState.itemCards.isEmpty ? 0 : theState.itemCards.last.index + 1;
        var newCard = ItemCardMdl(type: 0, index: idx, price: 20000);
        emit((state as InputserviceLoaded)
            .copyWith(itemCards: theState.itemCards + [newCard]));
      }
    });
    on<ChangeItemType>((event, emit) {
      var theState = (state as InputserviceLoaded);
      var price = switch (event.type) {
        0 => 20000,
        1 => 5000,
        int() => 0,
      };
      emit((state as InputserviceLoaded).copyWith(
          itemCards: theState.itemCards
              .map((e) => e.index == event.idx
                  ? e.copyWith(type: event.type, price: price)
                  : e)
              .toList()));
    });
    on<ChangeKaryawan>((event, emit) {
      if (state is InputserviceLoaded) {
        print('was hereas');
        emit((state as InputserviceLoaded)
            .copyWith(karyawanName: event.karyawanName));
      }
    });
  }
}
