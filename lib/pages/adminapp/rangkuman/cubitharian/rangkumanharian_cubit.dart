import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/model/perperson.dart';
import 'package:groom/model/struk_mdl.dart';

part 'rangkumanharian_state.dart';

class RangkumanDayCubit extends Cubit<RangkumanDayState> {
  PemasukanRepository repoPemasukan;
  PengeluaranRepository repoPengeluaran;
  RangkumanDayCubit(this.repoPemasukan, this.repoPengeluaran)
      : super(RangkumanDayInitial());
  loadData(Map filter) async {
    var a = await repoPemasukan.getStrukFiltered(filter);
    var b =
        await repoPengeluaran.getOperasionalOnly(tgl: filter['tanggalStart']);
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
          total += eSum.price * (eSum.pcsBarang ?? 1);
        }
        perPerson.add(PerPerson(
            namaKaryawan: e1.namaKaryawan,
            totalPendapatan: total,
            perCategory: e1.itemCards));
      }
    }
    for (var e in b) {
      operasionalTotal += e.biaya * e.pcs;
    }
    emit(RangkumanDayLoaded(
        qristotal: qrisTotal,
        operasional: operasionalTotal,
        tanggalStart: filter['tanggalStart'],
        tanggalEnd: filter['tanggalEnd'],
        incomePerPerson: perPerson));
  }
}
