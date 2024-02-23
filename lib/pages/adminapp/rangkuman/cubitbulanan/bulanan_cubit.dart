import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:groom/db/pemasukan_repo.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/model/struk_mdl.dart';

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
    num totalPemasukanqris = 0;

    ///pemasukan
    var dataPemasukan = await repoPemasukan.getStrukFiltered({
      'tanggalStart': thismonth,
      'tanggalEnd': nextmonth,
    });
    List<num> incomePerHari = List.generate(
        DateTime(dateTime.year, dateTime.month + 1)
            .subtract(Durations.long1)
            .day,
        (index) => 0);
    for (var e in dataPemasukan) {
      num totalPerStruk = 0;
      for (var card in e.itemCards) {
        totalPerStruk += card.pcsBarang * card.price;
      }
      totalPemasukan += totalPerStruk;
      totalPemasukanqris +=
          e.tipePembayaran == TipePembayaran.qris ? totalPerStruk : 0;
      incomePerHari[e.tanggal.day] += totalPerStruk;
    }

    ///pengeluaran
    var dataPengeluaran = await repoPengeluaran.getFiltered(
      tglStart: thismonth,
      tglEnd: nextmonth,
    );
    for (var e in dataPengeluaran) {
      totalPengeluaran += e.biaya * e.pcs;
    }
    emit(BulananState(
        totalPengeluaran: totalPengeluaran,
        totalPemasukan: totalPemasukan,
        incomePerHari: incomePerHari));
  }
}
