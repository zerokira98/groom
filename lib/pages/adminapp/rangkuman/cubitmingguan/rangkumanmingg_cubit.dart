import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:groom/db/bon_repo.dart';
import 'package:groom/db/pemasukan_repo.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/etc/globalvar.dart';
import 'package:groom/model/bondata_mdl.dart';
import 'package:groom/model/itemcard_mdl.dart';
import 'package:groom/model/pengeluaran_mdl.dart';
import 'package:groom/model/perperson.dart';
import 'package:groom/model/struk_mdl.dart';
import 'package:collection/collection.dart' as c;
part 'rangkumanmingg_state.dart';

class RangkumanWeekCubit extends Cubit<RangkumanWeekState> {
  PemasukanRepository repoPemasukan;
  BonRepository repoBon;
  PengeluaranRepository repoKeluar;
  RangkumanWeekCubit(this.repoPemasukan, this.repoBon, this.repoKeluar)
      : super(RangkumanWeekInitial());

  ///Map filter =>require start senin->end minggu 00:00 => 23.59
  loadData(Map filter) async {
    var ts = filter['tanggalStart'] as DateTime;
    var te = filter['tanggalEnd'] as DateTime;
    GroupBy groupBy = filter['groupBy'] ?? GroupBy.namaKayrawan;

    var jumlahPiutang = 0;
    var jumlahPiutangTerbayar = 0;
    var bon = await repoBon.getBonFiltered(Filter.and(
      Filter('tanggal',
          isGreaterThanOrEqualTo: Timestamp.fromDate(DateUtils.dateOnly(ts))),
      Filter('tanggal', isLessThan: Timestamp.fromDate(DateUtils.dateOnly(te))),
    ));
    var pengeluaran = await repoKeluar.getFiltered(tglStart: ts, tglEnd: te);
    Map<TipePengeluaran, List<PengeluaranMdl>> groupPengeluaran = c.groupBy(
      pengeluaran,
      (p0) => p0.tipePengeluaran,
    );
    Map groupAndSum = {};
    groupPengeluaran.forEach((key, v) {
      groupAndSum[key] = {
        'list': v,
        'sum': v.fold(
            0.0, (prev, element) => prev + (element.biaya * element.pcs)),
      };
    });
    var totalKeluar = 0.0;
    for (var e in pengeluaran) {
      totalKeluar += e.biaya * e.pcs;
    }
    for (var e in bon) {
      switch (e.tipe) {
        case BonType.berhutang:
          jumlahPiutang += e.jumlahBon;
          break;
        case BonType.bayarhutang:
          jumlahPiutangTerbayar += e.jumlahBon;
          break;
        default:
      }
    }
    List<List<PerPerson>> perDay = [];
    List<List<PerPerson>> perDay2 = [];
    for (var i = 0; i < 7; i++) {
      ///change to get daily
      var a = await repoPemasukan.getStrukFiltered({
        'tanggalStart': DateTime(ts.year, ts.month, ts.day + i),
        'tanggalEnd': DateTime(ts.year, ts.month, ts.day + i + 1),
      });
      List<PerPerson> perPerson = [];
      List<PerPerson> perPersonwithCut = [];

      ///can be optimize/beautify
      for (var e1 in a) {
        var firstFound =
            perPerson.where((e2) => e2.namaKaryawan == e1.namaKaryawan);
        var firstFound2 =
            perPersonwithCut.where((e2) => e2.namaKaryawan == e1.namaKaryawan);
        if (firstFound.isNotEmpty && firstFound2.isNotEmpty) {
          var total = 0;
          var totalwithCut = 0.0;
          List<ItemCardMdl> awoo = firstFound.first.perCategory;
          List<ItemCardMdl> awoo2 = firstFound2.first.perCategory;
          for (var eSum in e1.itemCards) {
            awoo = awoo
                .map((e) => e.type == eSum.type
                    ? e.copyWith(price: e.price + eSum.price)
                    : e)
                .toList();
            // num totalPerItemcard = eSum.price * (eSum.pcsBarang);
            // var newCardData = ItemCardMdl(
            //     index: eSum.index, type: eSum.type, price: totalPerItemcard);

            total += eSum.price * (eSum.pcsBarang);
            if (eSum.type == 0 && eSum.price == 20000) {
              totalwithCut += eSum.price * (eSum.pcsBarang) * 0.5;

              awoo2 = awoo2
                  .map((e) => e.type == eSum.type
                      ? e.copyWith(
                          price: e.price +
                              (eSum.price * (eSum.pcsBarang) * 0.5).toInt())
                      : e)
                  .toList();
            } else {
              totalwithCut +=
                  eSum.price * (eSum.pcsBarang) * cutPercentage(eSum.type);
              awoo2 = awoo2
                  .map((e) => e.type == eSum.type
                      ? e.copyWith(
                          price: e.price +
                              (eSum.price *
                                      (eSum.pcsBarang) *
                                      cutPercentage(eSum.type))
                                  .toInt())
                      : e)
                  .toList();
            }
            // totalwithCut +=
            //     eSum.price * (eSum.pcsBarang) * cutPercentage(eSum.type);
          }
          total += perPerson
              .firstWhere((e3) => e3.namaKaryawan == e1.namaKaryawan)
              .totalPendapatan;
          totalwithCut += perPersonwithCut
              .firstWhere((e3) => e3.namaKaryawan == e1.namaKaryawan)
              .totalPendapatan;

          ///
          perPersonwithCut = perPersonwithCut
              .map((ea) => ea.namaKaryawan == e1.namaKaryawan
                  ? ea.copyWith(
                      totalPendapatan: totalwithCut.toInt(), perCategory: awoo2)
                  : ea)
              .toList();
          perPerson = perPerson
              .map((ea) => ea.namaKaryawan == e1.namaKaryawan
                  ? ea.copyWith(totalPendapatan: total, perCategory: awoo)
                  : ea)
              .toList();
          //// end if exist
          // print(totalwithCut);
        } else if (firstFound.isEmpty) {
          var total = 0;
          var totalwithCut = 0.0;
          List<ItemCardMdl> groundItemCards = List.generate(
              cardType.length, (i) => ItemCardMdl(index: 0, price: 0, type: i));
          List<ItemCardMdl> groundItemCardscut = List.generate(
              cardType.length, (i) => ItemCardMdl(index: 0, price: 0, type: i));
          for (var eSum in e1.itemCards) {
            groundItemCards = groundItemCards.map((e) {
              return e.type == eSum.type
                  ? e.copyWith(price: e.price + eSum.price)
                  : e;
            }).toList();
            total += eSum.price * (eSum.pcsBarang);
            if (eSum.type == 0 && eSum.price == 20000) {
              totalwithCut += eSum.price * (eSum.pcsBarang) * 0.5;

              groundItemCardscut = groundItemCardscut.map((e) {
                return e.type == eSum.type
                    ? e.copyWith(
                        price: e.price +
                            (eSum.price * (eSum.pcsBarang) * 0.5).toInt())
                    : e;
              }).toList();
            } else {
              totalwithCut +=
                  eSum.price * (eSum.pcsBarang) * cutPercentage(eSum.type);
              groundItemCardscut = groundItemCardscut.map((e) {
                return e.type == eSum.type
                    ? e.copyWith(
                        price: e.price +
                            (eSum.price *
                                    (eSum.pcsBarang) *
                                    cutPercentage(eSum.type))
                                .toInt())
                    : e;
              }).toList();
            }
          }

          perPerson.add(PerPerson(
              namaKaryawan: e1.namaKaryawan,
              totalPendapatan: total,
              perCategory: groundItemCards));
          perPersonwithCut.add(PerPerson(
              namaKaryawan: e1.namaKaryawan,
              totalPendapatan: totalwithCut.toInt(),
              perCategory: groundItemCardscut));
        }
      }
      // Map<DateTime, List<PerPerson>> newMap = {
      //   DateTime(ts.year, ts.month, ts.day + i): perPerson
      // };
      // Map<DateTime, List<PerPerson>> newMap2 = {
      //   DateTime(ts.year, ts.month, ts.day + i): perPersonwithCut
      // };
      perDay.add(perPerson);
      perDay2.add(perPersonwithCut);
    }
    // print('aw$perDay2');

    var totalIncomeKotor = 0;
    var totalIncomewithcut = 0;
    for (var i = 0; i < 7; i++) {
      for (var z in perDay[i]) {
        totalIncomeKotor += z.totalPendapatan;
      }
      for (var x in perDay2[i]) {
        totalIncomewithcut += x.totalPendapatan;
      }
    }
    Map<String, List<ItemCardMdl>> perPerson = {};
    Map<String, List<ItemCardMdl>> perPersoncut = {};
    // Map<String, List<PerPerson>> perDay = {};
    // Map<String, List<PerPerson>> perDay2 = {};
    // for (var i = 0; i < 7; i++) {
    //   perDay.addAll({(i + ts.day).toString(): []});
    //   perDay2.addAll({(i + ts.day).toString(): []});
    // }

    ///weekly
    var a = await repoPemasukan.getStrukFiltered({
      'tanggalStart': DateTime(ts.year, ts.month, ts.day),
      'tanggalEnd': DateTime(te.year, te.month, te.day),
    });
    // var a2 = a.groupListsBy((element) => element.tanggal.day);
    // debugPrint(a2.toString());

    ///too many loop @_@
    for (var e1 in a) {
      ///per day
      // if (perDay.containsKey(e1.tanggal.day)) {
      //   if (perDay[e1.tanggal.day]?.isNotEmpty ?? false) {
      //     perDay[e1.tanggal.day].
      //   }
      // }
      // if (perDay2.containsKey(e1.tanggal.day)) {}

      ///end per day
      if (perPerson.keys.contains(e1.namaKaryawan)) {
        ///loop
        for (var e2 in e1.itemCards) {
          if (perPerson[e1.namaKaryawan]!
              .any((element) => element.type == e2.type)) {
            perPerson[e1.namaKaryawan] = perPerson[e1.namaKaryawan]!
                .map((ea) => e2.type == ea.type
                    ? ea.copyWith(price: ea.price + (e2.pcsBarang * e2.price))
                    : ea)
                .toList();
            perPersoncut[e1.namaKaryawan] =
                perPersoncut[e1.namaKaryawan]!.map((ea) {
              if (ea.type == e2.type) {
                num totcut = 0.0;
                if (e2.type == 0 && e2.price == 20000) {
                  totcut = ea.price + (e2.pcsBarang * e2.price * 0.5);
                } else {
                  totcut = ea.price +
                      (e2.pcsBarang * e2.price * cutPercentage(e2.type));
                }
                // print(totcut);
                return ea.copyWith(price: totcut.toInt());
              } else {
                return ea;
              }
            }).toList();
          } else {
            perPerson[e1.namaKaryawan]!.add(e2);
            perPersoncut[e1.namaKaryawan]!.add(e2.copyWith(
                price: (e2.type == 0 && e2.price == 20000)
                    ? (e2.pcsBarang * e2.price * 0.5).toInt()
                    : (e2.pcsBarang * e2.price * cutPercentage(e2.type))
                        .toInt()));
          }
        } //endloop
      } else {
        ///here
        ///
        List<ItemCardMdl> groundItemCards = List.generate(
            cardType.length, (i) => ItemCardMdl(index: 0, price: 0, type: i));
        List<ItemCardMdl> groundItemCardscut = List.generate(
            cardType.length, (i) => ItemCardMdl(index: 0, price: 0, type: i));
        for (var telo in e1.itemCards) {
          groundItemCards = groundItemCards
              .map((e) => e.type == telo.type
                  ? e.copyWith(price: e.price + (telo.pcsBarang * telo.price))
                  : e)
              .toList();
          if (telo.type == 0 && telo.price == 20000) {
            groundItemCardscut = groundItemCardscut.map((e) {
              return e.type == telo.type
                  ? e.copyWith(
                      price: e.price +
                          (telo.price * (telo.pcsBarang) * 0.5).toInt())
                  : e;
            }).toList();
          } else {
            groundItemCardscut = groundItemCardscut.map((e) {
              return e.type == telo.type
                  ? e.copyWith(
                      price: e.price +
                          (telo.price *
                                  (telo.pcsBarang) *
                                  cutPercentage(telo.type))
                              .toInt())
                  : e;
            }).toList();
          }
        }
        perPerson.addAll({e1.namaKaryawan: groundItemCards});

        perPersoncut.addAll({e1.namaKaryawan: groundItemCardscut});
      }
    }
    List<StrukMdl> dataPerPerson = [];
    List<StrukMdl> dataPerPerson2 = [];
    perPerson.forEach(
      (key, value) {
        dataPerPerson.add(StrukMdl(
            namaKaryawan: key,
            tanggal: DateTime.now(),
            itemCards: value,
            tipePembayaran: TipePembayaran.cash));
      },
    );
    perPersoncut.forEach(
      (key, value) {
        dataPerPerson2.add(StrukMdl(
            namaKaryawan: key,
            tanggal: DateTime.now(),
            itemCards: value,
            tipePembayaran: TipePembayaran.cash));
      },
    );
    // perDay2.forEachIndexed(
    //   (i, element) => print(i.toString() + element.toString()),
    // );
    emit(RangkumanWeekLoaded(
      bon: jumlahPiutangTerbayar - jumlahPiutang,
      groupBy: groupBy,
      pengeluaranlist: groupAndSum,
      pengeluaran: totalKeluar,
      tanggalStart: filter['tanggalStart'],
      tanggalEnd: filter['tanggalEnd'],
      dataPerPerson: dataPerPerson,
      dataPerPersoncut: dataPerPerson2,
      daily: perDay,
      dailycut: perDay2,
      totalKotor: totalIncomeKotor,
      totalBagiHasil: totalIncomewithcut,
    ));
    // }
  }
}
