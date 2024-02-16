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
      if (state is InputserviceLoaded) {
        var theState = state as InputserviceLoaded;
        emit(InputserviceLoaded(
            tipePembayaran: TipePembayaran.cash,
            karyawanName: theState.karyawanName,
            itemCards: const [],
            tanggal: DateTime.now()));
      } else {
        var a = await karyawanrepo.getAllKaryawan();
        emit(InputserviceLoaded(
            tipePembayaran: TipePembayaran.cash,
            karyawanName: a.first.namaKaryawan,
            itemCards: const [],
            tanggal: DateTime.now()));
      }
    });
    on<SubmitToDB>((event, emit) async {
      var theState = (state as InputserviceLoaded);
      var a = StrukMdl(
          tipePembayaran: theState.tipePembayaran,
          namaKaryawan: theState.karyawanName,
          tanggal: theState.tanggal.day == DateTime.now().day
              ? DateTime.now()
              : theState.tanggal,
          itemCards: theState.itemCards);

      try {
        var x = await strukrepo.insertStruk(a);

        // print(x);
        emit(InputserviceLoaded(
            tipePembayaran: TipePembayaran.cash,
            tanggal: DateTime.now(),
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
    on<ChangeTipePembayaran>((event, emit) {
      // var theState = (state as InputserviceLoaded);
      if (state is InputserviceLoaded) {
        emit((state as InputserviceLoaded).copyWith(
          tipePembayaran: event.type,
        ));
      }
    });
    on<ChangeKaryawan>((event, emit) {
      if (state is InputserviceLoaded) {
        emit((state as InputserviceLoaded)
            .copyWith(karyawanName: event.karyawanName));
      }
    });
    on<ChangeTanggal>((event, emit) {
      if (state is InputserviceLoaded) {
        emit((state as InputserviceLoaded).copyWith(tanggal: event.tanggal));
      }
    });
  }
}
