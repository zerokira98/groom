import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:groom/db/db.dart';
import 'package:groom/model/itemcard_mdl.dart';
import 'package:groom/model/struk_mdl.dart';

part 'inputservice_event.dart';
part 'inputservice_state.dart';

class InputserviceBloc extends Bloc<InputserviceEvent, InputserviceState> {
  PemasukanRepository strukrepo;
  KaryawanRepository karyawanrepo;
  BarangRepository barangrepo;
  MidApi midApi;
  InputserviceBloc({
    required this.strukrepo,
    required this.midApi,
    required this.karyawanrepo,
    required this.barangrepo,
  }) : super(InputserviceInitial()) {
    on<Initiate>((event, emit) async {
      if (state is InputserviceLoaded) {
        var theState = state as InputserviceLoaded;
        emit(InputserviceLoaded(
            tipePembayaran: TipePembayaran.cash,
            karyawanName: theState.karyawanName,
            itemCards: const [],
            tanggal: DateTime.now()));
      } else {
        var a = await karyawanrepo.getAllKaryawan(true);
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
      Timestamp tanggal = a.toJson().remove('tanggal');
      var jsonA = a.toJson()..remove('tanggal');
      jsonA.addAll({'tanggal': tanggal.toDate().toIso8601String()});
      try {
        for (var e in a.itemCards) {
          if (e.type == 3) {
            barangrepo.find(e.namaBarang).then((v) {
              if (v.isNotEmpty) {
                var single = v.first;
                barangrepo.edit(single.copyWith(pcs: single.pcs - e.pcsBarang));
              }
            });
          }
        }
        emit(InputserviceLoading());
        if (a.tipePembayaran == TipePembayaran.qris) {
          await strukrepo.insertStruk(a).then(
            (value) async {
              var res = await midApi
                  .getFlutterTest(
                      jsonEncode(jsonA..update('id', (v) => value.id)))
                  .then(
                (val) {
                  print(val.headers['content-type']);
                  if (!(val.headers['content-type']
                          ?.contains("application/json") ??
                      true)) {
                    value.delete();
                    print('not json!');
                    throw Exception('not json. code : ${val.statusCode}');
                  }
                  return val;
                },
              ).timeout(
                const Duration(seconds: 15),
                onTimeout: () {
                  value.delete();
                  throw Exception('no connection to midtrans');
                },
              );
              print(jsonDecode(res.body));
              emit(InputserviceLoaded(
                  tipePembayaran: a.tipePembayaran,
                  tanggal: DateTime.now(),
                  karyawanName: theState.karyawanName,
                  itemCards: const [],
                  success:
                      '{"qrcode_url":"${jsonDecode(res.body)['qrcode_url']}"}'));
              return value;
            },
          );
        } else {
          await strukrepo.insertStruk(a);
          emit(InputserviceLoaded(
              tipePembayaran: a.tipePembayaran,
              tanggal: DateTime.now(),
              karyawanName: theState.karyawanName,
              itemCards: const [],
              success: 'sukses !'));
        }
      } catch (e) {
        debugPrint('catched err$e');
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
