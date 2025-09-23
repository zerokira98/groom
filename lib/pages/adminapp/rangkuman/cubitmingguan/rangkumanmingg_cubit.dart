import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:groom/db/db.dart';
import 'package:groom/model/model.dart';
part 'rangkumanmingg_state.dart';

class RangkumanWeekCubit extends Cubit<RangkumanWeekState> {
  PemasukanRepository repoPemasukan;
  BonRepository repoBon;
  PengeluaranRepository repoKeluar;
  RangkumanWeekCubit(this.repoPemasukan, this.repoBon, this.repoKeluar)
    : super(RangkumanWeekInitial());

  ///Map filter =>require start senin->end minggu 00:00 => 23.59
  Future<void> loadData(Map filter) async {
    throw UnimplementedError();
    // var ts = filter['tanggalStart'] as DateTime;
    // var te = filter['tanggalEnd'] as DateTime;
    // GroupBy groupBy = filter['groupBy'] ?? GroupBy.namaKayrawan;

    // var jumlahPiutang = 0;
    // var jumlahPiutangTerbayar = 0;
    // var bon = await repoBon.getBonFiltered(
    //   Filter.and(
    //     Filter(
    //       'tanggal',
    //       isGreaterThanOrEqualTo: Timestamp.fromDate(DateUtils.dateOnly(ts)),
    //     ),
    //     Filter(
    //       'tanggal',
    //       isLessThan: Timestamp.fromDate(DateUtils.dateOnly(te)),
    //     ),
    //   ),
    // );
    // var pengeluaran = await repoKeluar.getFiltered(tglStart: ts, tglEnd: te);
    // Map<TipePengeluaran, List<PengeluaranMdl>> groupPengeluaran = c.groupBy(
    //   pengeluaran,
    //   (p0) => p0.tipePengeluaran,
    // );
    // Map groupAndSum = {};
    // groupPengeluaran.forEach((key, v) {
    //   groupAndSum[key] = {
    //     'list': v,
    //     'sum': v.fold(
    //       0.0,
    //       (prev, element) => prev + (element.biaya * element.pcs),
    //     ),
    //   };
    // });
    // var totalKeluar = 0.0;
    // for (var e in pengeluaran) {
    //   totalKeluar += e.biaya * e.pcs;
    // }
    // for (var e in bon) {
    //   switch (e.tipe) {
    //     case BonType.berhutang:
    //       jumlahPiutang += e.jumlahBon;
    //       break;
    //     case BonType.bayarhutang:
    //       jumlahPiutangTerbayar += e.jumlahBon;
    //       break;
    //   }
    // }
    // List<List<PerPerson>> perDay = [];
    // List<List<PerPerson>> perDay2 = [];
    // for (var i = 0; i < 7; i++) {
    //   ///change to get daily
    //   var a = await repoPemasukan.getStrukFiltered({
    //     'tanggalStart': DateTime(ts.year, ts.month, ts.day + i),
    //     'tanggalEnd': DateTime(ts.year, ts.month, ts.day + i + 1),
    //   });
    //   List<PerPerson> perPerson = [];
    //   List<PerPerson> perPersonwithCut = [];

    //   ///can be optimize/beautify
    //   for (var e1 in a) {
    //     var firstFound = perPerson.where(
    //       (e2) => e2.namaKaryawan == e1.namaKaryawan,
    //     );
    //     var firstFound2 = perPersonwithCut.where(
    //       (e2) => e2.namaKaryawan == e1.namaKaryawan,
    //     );
    //     if (firstFound.isNotEmpty && firstFound2.isNotEmpty) {
    //       var total = 0;
    //       var totalwithCut = 0.0;
    //       List<ItemCardMdl> awoo = firstFound.first.perCategory;
    //       List<ItemCardMdl> awoo2 = firstFound2.first.perCategory;
    //       for (var eSum in e1.itemCards) {
    //         awoo = awoo
    //             .map(
    //               (e) => e.id == eSum.id
    //                   ? e.copyWith(price: e.price + eSum.price)
    //                   : e,
    //             )
    //             .toList();
    //         // num totalPerItemcard = eSum.price * (eSum.pcs);
    //         // var newCardData = ItemCardMdl(
    //         //     index: eSum.index, type: eSum.type, price: totalPerItemcard);

    //         total += eSum.price * (eSum.pcs);
    //         totalwithCut +=
    //             (eSum.pcs) * eSum.price.cutPercentage(eSum.id);
    //         awoo2 = awoo2
    //             .map(
    //               (e) => e.id == eSum.id
    //                   ? e.copyWith(
    //                       price:
    //                           e.price +
    //                           ((eSum.pcs) *
    //                                   eSum.price.cutPercentage(eSum.id))
    //                               .toInt(),
    //                     )
    //                   : e,
    //             )
    //             .toList();
    //       }
    //       total += perPerson
    //           .firstWhere((e3) => e3.namaKaryawan == e1.namaKaryawan)
    //           .totalPendapatan;
    //       totalwithCut += perPersonwithCut
    //           .firstWhere((e3) => e3.namaKaryawan == e1.namaKaryawan)
    //           .totalPendapatan;

    //       ///
    //       perPersonwithCut = perPersonwithCut
    //           .map(
    //             (ea) => ea.namaKaryawan == e1.namaKaryawan
    //                 ? ea.copyWith(
    //                     totalPendapatan: totalwithCut.toInt(),
    //                     perCategory: awoo2,
    //                   )
    //                 : ea,
    //           )
    //           .toList();
    //       perPerson = perPerson
    //           .map(
    //             (ea) => ea.namaKaryawan == e1.namaKaryawan
    //                 ? ea.copyWith(totalPendapatan: total, perCategory: awoo)
    //                 : ea,
    //           )
    //           .toList();
    //     } else if (firstFound.isEmpty) {
    //       var total = 0;
    //       var totalwithCut = 0.0;
    //       List<ItemCardMdl> groundItemCards = List.generate(
    //         cardType.length,
    //         (i) => ItemCardMdl(index: 0, price: 0, id: i),
    //       );
    //       List<ItemCardMdl> groundItemCardscut = List.generate(
    //         cardType.length,
    //         (i) => ItemCardMdl(index: 0, price: 0, id: i),
    //       );
    //       for (var eSum in e1.itemCards) {
    //         groundItemCards = groundItemCards.map((e) {
    //           return e.id == eSum.id
    //               ? e.copyWith(price: e.price + eSum.price)
    //               : e;
    //         }).toList();
    //         total += eSum.price * (eSum.pcs);
    //         totalwithCut +=
    //             (eSum.pcs) * eSum.price.cutPercentage(eSum.id);
    //         groundItemCardscut = groundItemCardscut.map((e) {
    //           return e.id == eSum.id
    //               ? e.copyWith(
    //                   price:
    //                       e.price +
    //                       ((eSum.pcs) * eSum.price.cutPercentage(eSum.id))
    //                           .toInt(),
    //                 )
    //               : e;
    //         }).toList();
    //       }

    //       perPerson.add(
    //         PerPerson(
    //           namaKaryawan: e1.namaKaryawan,
    //           totalPendapatan: total,
    //           perCategory: groundItemCards,
    //         ),
    //       );
    //       perPersonwithCut.add(
    //         PerPerson(
    //           namaKaryawan: e1.namaKaryawan,
    //           totalPendapatan: totalwithCut.toInt(),
    //           perCategory: groundItemCardscut,
    //         ),
    //       );
    //     }
    //   }
    //   perDay.add(perPerson);
    //   perDay2.add(perPersonwithCut);
    // }

    // var totalIncomeKotor = 0;
    // var totalIncomewithcut = 0;
    // for (var i = 0; i < 7; i++) {
    //   for (var z in perDay[i]) {
    //     totalIncomeKotor += z.totalPendapatan;
    //   }
    //   for (var x in perDay2[i]) {
    //     totalIncomewithcut += x.totalPendapatan;
    //   }
    // }
    // Map<String, List<ItemCardMdl>> perPerson = {};
    // Map<String, List<ItemCardMdl>> perPersoncut = {};

    // ///weekly
    // var a = await repoPemasukan.getStrukFiltered({
    //   'tanggalStart': DateTime(ts.year, ts.month, ts.day),
    //   'tanggalEnd': DateTime(te.year, te.month, te.day),
    // });

    // ///too many loop @_@
    // for (var e1 in a) {
    //   ///end per day
    //   if (perPerson.keys.contains(e1.namaKaryawan)) {
    //     ///loop
    //     for (var e2 in e1.itemCards) {
    //       if (perPerson[e1.namaKaryawan]!.any(
    //         (element) => element.id == e2.id,
    //       )) {
    //         perPerson[e1.namaKaryawan] = perPerson[e1.namaKaryawan]!
    //             .map(
    //               (ea) => e2.id == ea.id
    //                   ? ea.copyWith(price: ea.price + (e2.pcs * e2.price))
    //                   : ea,
    //             )
    //             .toList();
    //         perPersoncut[e1.namaKaryawan] = perPersoncut[e1.namaKaryawan]!.map((
    //           ea,
    //         ) {
    //           if (ea.id == e2.id) {
    //             num totcut = 0.0;
    //             totcut =
    //                 ea.price + (e2.pcs * e2.price.cutPercentage(e2.id));
    //             // print(totcut);
    //             return ea.copyWith(price: totcut.toInt());
    //           } else {
    //             return ea;
    //           }
    //         }).toList();
    //       } else {
    //         perPerson[e1.namaKaryawan]!.add(e2);
    //         perPersoncut[e1.namaKaryawan]!.add(
    //           e2.copyWith(
    //             price: (e2.pcs * e2.price.cutPercentage(e2.id)).toInt(),
    //           ),
    //         );
    //       }
    //     } //endloop
    //   } else {
    //     ///here
    //     ///
    //     List<ItemCardMdl> groundItemCards = List.generate(
    //       cardType.length,
    //       (i) => ItemCardMdl(index: 0, price: 0, id: i),
    //     );
    //     List<ItemCardMdl> groundItemCardscut = List.generate(
    //       cardType.length,
    //       (i) => ItemCardMdl(index: 0, price: 0, id: i),
    //     );
    //     for (var telo in e1.itemCards) {
    //       groundItemCards = groundItemCards
    //           .map(
    //             (e) => e.id == telo.id
    //                 ? e.copyWith(price: e.price + (telo.pcs * telo.price))
    //                 : e,
    //           )
    //           .toList();
    //       groundItemCardscut = groundItemCardscut.map((e) {
    //         return e.id == telo.id
    //             ? e.copyWith(
    //                 price:
    //                     e.price +
    //                     ((telo.pcs) * telo.cutPercentage(telo.id))
    //                         .toInt(),
    //               )
    //             : e;
    //       }).toList();
    //     }
    //     perPerson.addAll({e1.namaKaryawan: groundItemCards});

    //     perPersoncut.addAll({e1.namaKaryawan: groundItemCardscut});
    //   }
    // }
    // List<StrukMdl> dataPerPerson = [];
    // List<StrukMdl> dataPerPerson2 = [];
    // perPerson.forEach((key, value) {
    //   dataPerPerson.add(
    //     StrukMdl(
    //       namaKaryawan: key,
    //       tanggal: DateTime.now(),
    //       itemCards: value,
    //       tipePembayaran: TipePembayaran.cash,
    //     ),
    //   );
    // });
    // perPersoncut.forEach((key, value) {
    //   dataPerPerson2.add(
    //     StrukMdl(
    //       namaKaryawan: key,
    //       tanggal: DateTime.now(),
    //       itemCards: value,
    //       tipePembayaran: TipePembayaran.cash,
    //     ),
    //   );
    // });
    // emit(
    //   RangkumanWeekLoaded(
    //     bon: jumlahPiutangTerbayar - jumlahPiutang,
    //     groupBy: groupBy,
    //     pengeluaranlist: groupAndSum,
    //     pengeluaran: totalKeluar,
    //     tanggalStart: filter['tanggalStart'],
    //     tanggalEnd: filter['tanggalEnd'],
    //     dataPerPerson: dataPerPerson,
    //     dataPerPersoncut: dataPerPerson2,
    //     daily: perDay,
    //     dailycut: perDay2,
    //     totalKotor: totalIncomeKotor,
    //     totalBagiHasil: totalIncomewithcut,
    //   ),
    // );
    // }
  }
}
