import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/model/itemcard_mdl.dart';
import 'package:groom/model/perperson.dart';
import 'package:groom/model/struk_mdl.dart';

part 'rangkumanmingg_state.dart';

class RangkumanWeekCubit extends Cubit<RangkumanWeekState> {
  PemasukanRepository repo;
  RangkumanWeekCubit(this.repo) : super(RangkumanWeekInitial());

  ///Map filter =>require start senin->end minggu 00:00 => 23.59
  loadData(Map filter) async {
    var ts = filter['tanggalStart'] as DateTime;
    var te = filter['tanggalEnd'] as DateTime;
    GroupBy groupBy = filter['groupBy'] ?? GroupBy.date;
    double cutPercentage(int type) => switch (type) {
          0 => 0.48,
          1 => 0.5,
          2 => 0.5,
          3 => 0.1,
          int() => 1,
        };
    if (groupBy == GroupBy.date) {
      List<Map<DateTime, List<PerPerson>>> perDay = [];
      List<Map<DateTime, List<PerPerson>>> perDay2 = [];
      for (var i = 0; i < 7; i++) {
        ///change to get daily
        var a = await repo.getStrukFiltered({
          'tanggalStart': DateTime(ts.year, ts.month, ts.day + i),
          'tanggalEnd': DateTime(ts.year, ts.month, ts.day + i)
              .add(const Duration(days: 1))
              .subtract(Durations.long2),
        });
        List<PerPerson> perPerson = [];
        List<PerPerson> perPersonwithCut = [];

        ///can be optimize/beautify
        for (var e1 in a) {
          if (perPerson.any((e2) => e2.namaKaryawan == e1.namaKaryawan)) {
            var total = 0;
            var totalwithCut = 0.0;
            for (var eSum in e1.itemCards) {
              total += eSum.price * (eSum.pcsBarang ?? 1);
              totalwithCut +=
                  eSum.price * (eSum.pcsBarang ?? 1) * cutPercentage(eSum.type);
            }
            total += perPerson
                    .firstWhere((e3) => e3.namaKaryawan == e1.namaKaryawan)
                    .totalPendapatan ??
                0;
            totalwithCut += perPersonwithCut
                    .firstWhere((e3) => e3.namaKaryawan == e1.namaKaryawan)
                    .totalPendapatan ??
                0;
            perPersonwithCut = perPersonwithCut
                .map((ea) => ea.namaKaryawan == e1.namaKaryawan
                    ? ea.copyWith(totalPendapatan: totalwithCut.toInt())
                    : ea)
                .toList();
            perPerson = perPerson
                .map((ea) => ea.namaKaryawan == e1.namaKaryawan
                    ? ea.copyWith(totalPendapatan: total)
                    : ea)
                .toList();
          } else if (perPerson
                  .any((e2) => e2.namaKaryawan == e1.namaKaryawan) ==
              false) {
            var total = 0;
            var totalwithCut = 0.0;
            for (var eSum in e1.itemCards) {
              total += eSum.price * (eSum.pcsBarang ?? 1);
              totalwithCut +=
                  eSum.price * (eSum.pcsBarang ?? 1) * cutPercentage(eSum.type);
            }
            perPerson.add(PerPerson(
                namaKaryawan: e1.namaKaryawan, totalPendapatan: total));
            perPersonwithCut.add(PerPerson(
                namaKaryawan: e1.namaKaryawan,
                totalPendapatan: totalwithCut.toInt()));
          }
        }
        Map<DateTime, List<PerPerson>> newMap = {
          DateTime(ts.year, ts.month, ts.day + i): perPerson
        };
        Map<DateTime, List<PerPerson>> newMap2 = {
          DateTime(ts.year, ts.month, ts.day + i): perPersonwithCut
        };
        perDay.add(newMap);
        perDay2.add(newMap2);
      }

      var totalIncomeKotor = 0;
      var totalIncomewithcut = 0;
      for (var i = 0; i < 7; i++) {
        for (var z in perDay[i].values.first) {
          totalIncomeKotor += z.totalPendapatan;
        }
        for (var x in perDay2[i].values.first) {
          totalIncomewithcut += x.totalPendapatan;
        }
      }

      emit(RangkumanWeekLoaded(
        groupBy: groupBy,
        tanggalStart: filter['tanggalStart'],
        tanggalEnd: filter['tanggalEnd'],
        daily: perDay,
        dataPerPerson: const [],
        totalKotor: totalIncomeKotor,
        totalBagiHasil: totalIncomewithcut,
      ));
    } else if (groupBy == GroupBy.namaKayrawan) {
      Map<String, List<ItemCardMdl>> perPerson = {};

      ///weekly
      var a = await repo.getStrukFiltered({
        'tanggalStart': DateTime(ts.year, ts.month, ts.day),
        'tanggalEnd': DateTime(te.year, te.month, te.day),
      });

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
              namaKaryawan: key, tanggal: DateTime.now(), itemCards: value));
        },
      );
      emit(RangkumanWeekLoaded(
        groupBy: groupBy,
        tanggalStart: filter['tanggalStart'],
        tanggalEnd: filter['tanggalEnd'],
        dataPerPerson: dataPerPerson,
        daily: const [],
        totalKotor: (state as RangkumanWeekLoaded).totalKotor,
        totalBagiHasil: (state as RangkumanWeekLoaded).totalBagiHasil,
      ));
    }
  }
}
