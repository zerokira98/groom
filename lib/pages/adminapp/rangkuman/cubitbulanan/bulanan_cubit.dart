import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:groom/db/pemasukan_repo.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/model/pengeluaran_mdl.dart';
import 'package:collection/collection.dart' as c;

part 'bulanan_state.dart';

class BulananCubit extends Cubit<BulananState> {
  PemasukanRepository repoPemasukan;
  PengeluaranRepository repoPengeluaran;

  BulananCubit(this.repoPemasukan, this.repoPengeluaran)
      : super(BulananState.initial());
  loadData(DateTime dateTime) async {
    DateTime thismonth = DateTime(dateTime.year, dateTime.month);
    DateTime nextmonth = DateTime(dateTime.year, dateTime.month + 1);
    num totalPengeluaran = 0;
    num totalPemasukan = 0;
    // num totalPemasukanqris = 0;

    ///pemasukan
    var dataPemasukan = await repoPemasukan.getStrukFiltered({
      'tanggalStart': thismonth,
      'tanggalEnd': nextmonth,
    });
    List<num> incomePerHari = List.generate(
        nextmonth.subtract(Durations.long1).day + 1, (index) => 0);
    List<num> customerPerHari = List.generate(
        nextmonth.subtract(Durations.long1).day + 1, (index) => 0);

    Map<String, num> pendapatanTertinggi = {'day': 0.0, 'sum': 0.0, 'count': 0};
    Map<String, num> jumlahCustomerTertinggi = {
      'day': 0.0,
      'sum': 0.0,
      'count': 0,
      'avg': 0,
      'emptyDays': 0
    };
    for (var e in dataPemasukan) {
      num totalPerStruk = 0;
      for (var card in e.itemCards) {
        totalPerStruk += card.pcsBarang * card.price;
      }
      totalPemasukan += totalPerStruk;
      // totalPemasukanqris +=
      //     e.tipePembayaran == TipePembayaran.qris ? totalPerStruk : 0;
      incomePerHari[e.tanggal.day] += totalPerStruk;
      customerPerHari[e.tanggal.day] += 1;
    }
    for (int j = 0; j < incomePerHari.length; j++) {
      var e = incomePerHari[j];
      var f = customerPerHari[j];
      if (pendapatanTertinggi['sum']! < e) {
        pendapatanTertinggi['day'] = j;
        pendapatanTertinggi['sum'] = e;
      }
      if (jumlahCustomerTertinggi['count']! < f) {
        jumlahCustomerTertinggi['day'] = j;
        jumlahCustomerTertinggi['count'] = f;
        jumlahCustomerTertinggi['sum'] = e;
      }
    }
    jumlahCustomerTertinggi['avg'] =
        customerPerHari.where((element) => element != 0).average;
    jumlahCustomerTertinggi['emptyDays'] =
        customerPerHari.where((element) => element == 0).length;
    pendapatanTertinggi['count'] = dataPemasukan
        .where((element) => element.tanggal.day == pendapatanTertinggi['day'])
        .toList()
        .length;

    ///pengeluaran
    var dataPengeluaran = await repoPengeluaran.getFiltered(
      tglStart: thismonth,
      tglEnd: nextmonth,
    );
    Map<int, List<PengeluaranMdl>> groupPengeluaran = c.groupBy(
      dataPengeluaran,
      (p0) => p0.tanggal.day,
    );
    Map groupAndSum = {};
    for (var i = 0; i <= nextmonth.subtract(Durations.long1).day; i++) {
      groupAndSum[i] = {'sum': 0};
    }
    groupPengeluaran.forEach((key, v) {
      groupAndSum[key] = {
        'list': v,
        'sum': v.fold(
            0.0, (prev, element) => prev + (element.biaya * element.pcs)),
      };
      // if (pendapatanTertinggi['sum']! < groupAndSum[key]['sum']) {
      //   pendapatanTertinggi['day'] = key;
      //   pendapatanTertinggi['sum'] = groupAndSum[key]['sum'];
      // }
    });
    for (var e in dataPengeluaran) {
      totalPengeluaran += e.biaya * e.pcs;
    }
    emit(BulananState(
        bulan: thismonth,
        pendapatanTertinggi: pendapatanTertinggi,
        jumlahCustomerTertinggi: jumlahCustomerTertinggi,
        groupAndSumPengeluaran: groupAndSum,
        totalPengeluaran: totalPengeluaran,
        totalPemasukan: totalPemasukan,
        incomePerHari: incomePerHari));
  }
}
