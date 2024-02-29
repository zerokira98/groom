import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:groom/db/bon_repo.dart';
import 'package:groom/db/pemasukan_repo.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/model/bondata_mdl.dart';
import 'package:groom/model/pengeluaran_mdl.dart';
import 'package:groom/model/perperson.dart';
import 'package:groom/model/struk_mdl.dart';

part 'rangkumanharian_state.dart';

class RangkumanDayCubit extends Cubit<RangkumanDayState> {
  PemasukanRepository repoPemasukan;
  PengeluaranRepository repoPengeluaran;
  BonRepository repoBon;
  RangkumanDayCubit(this.repoPemasukan, this.repoPengeluaran, this.repoBon)
      : super(RangkumanDayInitial());
  loadData(Map filter) async {
    var tsStart =
        Timestamp.fromDate(DateUtils.dateOnly(filter['tanggalStart']));
    var tsEnd = Timestamp.fromDate(DateUtils.dateOnly(filter['tanggalEnd']));
    var a = await repoPemasukan.getStrukFiltered(filter);
    var b =
        await repoPengeluaran.getOperasionalOnly(tgl: filter['tanggalStart']);
    List<BonData> c = await repoBon.getBonFiltered(Filter.and(
      Filter('author', isEqualTo: 'self'),
      Filter('tanggal', isGreaterThanOrEqualTo: tsStart),
      Filter('tanggal', isLessThan: tsEnd),
    ));
    var bontot = 0;
    for (var e in c) {
      bontot += e.tipe == BonType.berhutang ? e.jumlahBon : 0;
    }
    List<PerPerson> perPerson = [];
    num qrisTotal = 0;
    num operasionalTotal = 0;

    ///can be optimize/beautify
    for (var e1 in a) {
      if (e1.tipePembayaran == TipePembayaran.qris) {
        for (var ee in e1.itemCards) {
          qrisTotal += ee.pcsBarang * ee.price;
        }
      }
      if (perPerson.any((e2) => e2.namaKaryawan == e1.namaKaryawan)) {
        var total = 0;
        for (var eSum in e1.itemCards) {
          total += eSum.price * (eSum.pcsBarang);
        }
        total += perPerson
            .firstWhere((e3) => e3.namaKaryawan == e1.namaKaryawan)
            .totalPendapatan;
        perPerson = perPerson
            .map((ea) => ea.namaKaryawan == e1.namaKaryawan
                ? ea.copyWith(totalPendapatan: total)
                : ea)
            .toList();
      } else if (perPerson.any((e2) => e2.namaKaryawan == e1.namaKaryawan) ==
          false) {
        var total = 0;
        for (var eSum in e1.itemCards) {
          total += eSum.price * (eSum.pcsBarang);
        }
        perPerson.add(PerPerson(
            namaKaryawan: e1.namaKaryawan,
            totalPendapatan: total,
            perCategory: e1.itemCards));
      }
    }
    for (var e in b) {
      if (e.karyawan != null) {
        operasionalTotal += e.biaya * e.pcs;
      }
    }
    emit(RangkumanDayLoaded(
        qristotal: qrisTotal,
        operasional: operasionalTotal,
        pengeluaranList: b,
        bontotal: bontot,
        tanggalStart: DateUtils.dateOnly(filter['tanggalStart']),
        tanggalEnd: DateUtils.dateOnly(filter['tanggalEnd']),
        incomePerPerson: perPerson));
  }
}
