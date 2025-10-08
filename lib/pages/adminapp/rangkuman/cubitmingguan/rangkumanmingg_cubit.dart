import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart' as c;
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/material.dart' show DateUtils;
import 'package:groom/db/db.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/datafilter.dart';
import 'package:groom/model/model.dart';
import 'package:groom/pages/home/widgets/itemcard.dart';
part 'rangkumanmingg_state.dart';

class RangkumanWeekCubit extends Cubit<RangkumanWeekState> {
  PemasukanRepository repoPemasukan;
  BonRepository repoBon;
  PengeluaranRepository repoKeluar;
  RangkumanWeekCubit(this.repoPemasukan, this.repoBon, this.repoKeluar)
    : super(RangkumanWeekInitial());

  ///Map filter =>require start senin->end minggu 00:00 => 23.59
  Future<void> loadData(Datafilter filter) async {
    // throw UnimplementedError();
    // var ts = filter['tanggalStart'] as DateTime;
    // var te = filter['tanggalEnd'] as DateTime;
    // GroupBy groupBy = filter['groupBy'] ?? GroupBy.namaKayrawan;

    var jumlahPiutang = 0;
    var jumlahPiutangTerbayar = 0;

    ///======
    var bon = await repoBon.getBonFiltered(
      Filter.and(
        Filter(
          'tanggal',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateUtils.dateOnly(filter.start),
          ),
        ),
        Filter(
          'tanggal',
          isLessThan: Timestamp.fromDate(DateUtils.dateOnly(filter.end)),
        ),
      ),
    );
    var pengeluaran = await repoKeluar.getFiltered(
      tglStart: filter.start,
      tglEnd: filter.end,
    );
    Map<TipePengeluaran, List<PengeluaranMdl>> groupPengeluaran = c.groupBy(
      pengeluaran,
      (p0) => p0.tipePengeluaran,
    );
    Map groupAndSum = {};
    groupPengeluaran.forEach((key, v) {
      groupAndSum[key] = {
        'list': v,
        'sum': v.fold(
          0.0,
          (prev, element) => prev + (element.biaya * element.pcs),
        ),
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
      }
    }
    var a = await repoPemasukan.getStrukFiltered({
      'tanggalStart': filter.start.dmyDate(),
      'tanggalEnd': filter.start.dmyDate().add(Duration(days: 7)),
    });
    var totalKotor = a.fold(
      0,
      (previousValue, element) =>
          previousValue +
          (element.itemCards.fold(
            0,
            (previousValue2, element2) =>
                previousValue2 + (element2.pcs * element2.price),
          )),
    );
    var totalcut = a.fold(
      0,
      (previousValue, element) =>
          previousValue +
          (element.itemCards.fold(
            0,
            (previousValue2, element2) =>
                previousValue2 + (element2.pcs * element2.employeeCut),
          )),
    );
    Map<String, List<ServiceitemsMdl>> persons = {};
    List<StrukMdl> dataPerPerson = [];
    for (var ele in a) {
      persons.update(
        ele.namaKaryawan,
        (value) => value + ele.itemCards,
        ifAbsent: () => ele.itemCards,
      );
    }
    persons.forEach((key, value) {
      dataPerPerson.add(
        StrukMdl(
          namaKaryawan: key,
          tanggal: DateTime.now().dmyDate(),
          tipePembayaran: TipePembayaran.cash,
          itemCards: value,
        ),
      );
    });
    emit(
      RangkumanWeekLoaded(
        bon: jumlahPiutangTerbayar - jumlahPiutang,
        groupBy: GroupBy.namaKayrawan,
        pengeluaranlist: groupAndSum,
        pengeluaran: totalKeluar,
        filter: filter,
        dataPerPerson: dataPerPerson,
        daily: [],
        dailycut: [],
        totalKotor: totalKotor,
        totalBagiHasil: totalcut,
      ),
    );
    // }
  }
}
