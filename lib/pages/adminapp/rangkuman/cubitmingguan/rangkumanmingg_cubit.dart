import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:groom/db/bon_repo.dart';
import 'package:groom/db/pemasukan_repo.dart';
import 'package:groom/model/bondata_mdl.dart';
import 'package:groom/model/itemcard_mdl.dart';
import 'package:groom/model/perperson.dart';
import 'package:groom/model/struk_mdl.dart';

part 'rangkumanmingg_state.dart';

class RangkumanWeekCubit extends Cubit<RangkumanWeekState> {
  PemasukanRepository repoPemasukan;
  BonRepository repoBon;
  RangkumanWeekCubit(this.repoPemasukan, this.repoBon)
      : super(RangkumanWeekInitial());

  ///Map filter =>require start senin->end minggu 00:00 => 23.59
  loadData(Map filter) async {
    var ts = filter['tanggalStart'] as DateTime;
    var te = filter['tanggalEnd'] as DateTime;
    GroupBy groupBy = filter['groupBy'] ?? GroupBy.namaKayrawan;
    double cutPercentage(int type) => switch (type) {
          0 => 0.48,
          1 => 0.5,
          2 => 0.5,
          3 => 0.1,
          int() => 1,
        };
    var jumlahPiutang = 0;
    var jumlahPiutangTerbayar = 0;
    var bon = await repoBon.getAllBon();
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
        'tanggalEnd': DateTime(ts.year, ts.month, ts.day + i)
            .add(const Duration(days: 1)),
      });
      List<PerPerson> perPerson = [];
      List<PerPerson> perPersonwithCut = [];

      ///can be optimize/beautify
      for (var e1 in a) {
        var firstFound =
            perPerson.where((e2) => e2.namaKaryawan == e1.namaKaryawan);
        if (firstFound.isNotEmpty) {
          var total = 0;
          var totalwithCut = 0.0;
          List<ItemCardMdl> awoo = firstFound.first.perCategory;
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
            totalwithCut +=
                eSum.price * (eSum.pcsBarang) * cutPercentage(eSum.type);
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
                  ? ea.copyWith(totalPendapatan: totalwithCut.toInt())
                  : ea)
              .toList();
          perPerson = perPerson
              .map((ea) => ea.namaKaryawan == e1.namaKaryawan
                  ? ea.copyWith(totalPendapatan: total, perCategory: awoo)
                  : ea)
              .toList();
          //// end if exist
        } else if (firstFound.isEmpty) {
          var total = 0;
          var totalwithCut = 0.0;
          List<ItemCardMdl> groundItemCards = List.generate(
              cardType.length, (i) => ItemCardMdl(index: 0, price: 0, type: i));
          for (var eSum in e1.itemCards) {
            groundItemCards = groundItemCards
                .map((e) => e.type == eSum.type
                    ? e.copyWith(price: e.price + eSum.price)
                    : e)
                .toList();
            total += eSum.price * (eSum.pcsBarang);
            totalwithCut +=
                eSum.price * (eSum.pcsBarang) * cutPercentage(eSum.type);
          }

          perPerson.add(PerPerson(
              namaKaryawan: e1.namaKaryawan,
              totalPendapatan: total,
              perCategory: groundItemCards));
          perPersonwithCut.add(PerPerson(
              namaKaryawan: e1.namaKaryawan,
              totalPendapatan: totalwithCut.toInt(),
              perCategory: groundItemCards));
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

    // emit(RangkumanWeekLoaded(
    //   groupBy: groupBy,
    //   tanggalStart: filter['tanggalStart'],
    //   tanggalEnd: filter['tanggalEnd'],
    //   daily: perDay,
    //   dataPerPerson: const [],
    //   totalKotor: totalIncomeKotor,
    //   totalBagiHasil: totalIncomewithcut,
    // ));
    if (groupBy == GroupBy.namaKayrawan) {
      Map<String, List<ItemCardMdl>> perPerson = {};

      ///weekly
      var a = await repoPemasukan.getStrukFiltered({
        'tanggalStart': DateTime(ts.year, ts.month, ts.day),
        'tanggalEnd': DateTime(te.year, te.month, te.day),
      });
      print(a);

      ///too many loop @_@
      for (var e1 in a) {
        if (perPerson.keys.contains(e1.namaKaryawan)) {
          for (var e2 in e1.itemCards) {
            if (perPerson[e1.namaKaryawan]!
                .any((element) => element.type == e2.type)) {
              perPerson[e1.namaKaryawan] = perPerson[e1.namaKaryawan]!
                  .map((ea) => e2.type == ea.type
                      ? ea.copyWith(price: ea.price + (e2.pcsBarang * e2.price))
                      : ea)
                  .toList();
            } else {
              perPerson[e1.namaKaryawan]!.add(e2);
            }
          }
        } else {
          perPerson.addAll({e1.namaKaryawan: e1.itemCards});
        }
      }
      List<StrukMdl> dataPerPerson = [];
      perPerson.forEach(
        (key, value) {
          dataPerPerson.add(StrukMdl(
              namaKaryawan: key,
              tanggal: DateTime.now(),
              itemCards: value,
              tipePembayaran: TipePembayaran.cash));
        },
      );
      emit(RangkumanWeekLoaded(
        groupBy: groupBy,
        tanggalStart: filter['tanggalStart'],
        tanggalEnd: filter['tanggalEnd'],
        dataPerPerson: dataPerPerson,
        daily: perDay,
        totalKotor: totalIncomeKotor,
        totalBagiHasil: totalIncomewithcut,
      ));
    }
  }
}
