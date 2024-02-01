import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/model/perperson.dart';

part 'rangkumanharian_state.dart';

class RangkumanDayCubit extends Cubit<RangkumanDayState> {
  PemasukanRepository repo;
  RangkumanDayCubit(this.repo) : super(RangkumanDayInitial());
  loadData(Map filter) async {
    var a = await repo.getStrukFiltered(filter);
    List<PerPerson> perPerson = [];

    ///can be optimize/beautify
    for (var e1 in a) {
        if (perPerson.any((e2) => e2.namaKaryawan == e1.namaKaryawan)) {
          var total = 0;
          for (var eSum in e1.itemCards) {
            total += eSum.price * (eSum.pcsBarang ?? 1);
          }
          total += perPerson
                  .firstWhere((e3) => e3.namaKaryawan == e1.namaKaryawan)
                  .totalPendapatan ??
              0;
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
          perPerson.add(
              PerPerson(namaKaryawan: e1.namaKaryawan, totalPendapatan: total));
          //  = perPerson
          //     .map((ea) => ea.namaKaryawan == e1.namaKaryawan
          //         ? ea.copyWith(totalPendapatan: total)
          //         : ea)
          //     .toList();
        }
      }
    emit(RangkumanDayLoaded(
        tanggalStart: filter['tanggalStart'],
        tanggalEnd: filter['tanggalEnd'],
        incomePerPerson: perPerson));
  }
}
