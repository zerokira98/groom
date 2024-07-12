import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/itemcard_mdl.dart';
import 'package:groom/pages/home/riwayat_pemasukan/tile_struk.dart';
import 'cubitharian/rangkumanharian_cubit.dart';
import 'package:intl/intl.dart';
import 'package:weekly_date_picker/datetime_apis.dart';

class RangkumanHarian extends StatefulWidget {
  const RangkumanHarian({super.key});

  @override
  State<RangkumanHarian> createState() => _RangkumanHarianState();
}

class _RangkumanHarianState extends State<RangkumanHarian> {
  final DateFormat format = DateFormat('EEEE, d MMMM y', 'id_ID');

  var now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RangkumanDayCubit, RangkumanDayState>(
      builder: (context, state) {
        if (state is RangkumanDayLoaded) {
          var fullTotal = 0;
          for (var element in state.incomePerPerson) {
            fullTotal += element.totalPendapatan;
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Harian'),
            ),
            bottomNavigationBar: BottomAppBar(
                child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Total Pemasukan : ${fullTotal.numberFormat(currency: true)}'),
                      Text(
                          'Qris : ${state.qristotal.numberFormat(currency: true)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Pengeluaran+bon by karyawan: ${(state.operasional + state.bontotal).numberFormat(currency: true)}'),
                    ],
                  ),
                  Text(
                      'Total cash masuk laci: ${(fullTotal - state.qristotal - state.operasional - state.bontotal).toInt().numberFormat(currency: true)}'),
                ],
              ),
            )),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                        onPressed: () {
                          BlocProvider.of<RangkumanDayCubit>(context).loadData({
                            'tanggalStart': state.tanggalStart
                                .subtract(const Duration(days: 1)),
                            'tanggalEnd': state.tanggalEnd
                                .subtract(const Duration(days: 1)),
                          });
                        },
                        icon: const Icon(Icons.arrow_left)),
                    ElevatedButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            firstDate: DateTime(state.tanggalStart.year - 2),
                            lastDate: now.addDays(60),
                            initialDate: state.tanggalStart,
                          ).then((value) {
                            if (value != null) {
                              BlocProvider.of<RangkumanDayCubit>(context)
                                  .loadData({
                                'tanggalStart': value,
                                'tanggalEnd': value.addDays(1),
                              });
                            }
                          });
                        },
                        child: Text(
                            'Hari : ${format.format(DateTime(state.tanggalStart.year, state.tanggalStart.month, state.tanggalStart.day))}')),
                    IconButton(
                        onPressed: () {
                          BlocProvider.of<RangkumanDayCubit>(context).loadData({
                            'tanggalStart':
                                state.tanggalStart.add(const Duration(days: 1)),
                            'tanggalEnd':
                                state.tanggalEnd.add(const Duration(days: 1)),
                          });
                        },
                        icon: const Icon(Icons.arrow_right)),
                  ],
                ),
                Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                      Theme.of(context).primaryColorDark,
                                      Theme.of(context).primaryColorDark,
                                      Theme.of(context)
                                          .primaryColorDark
                                          .withOpacity(0.45)
                                    ])),
                                    child: const Text('Pemasukan')),
                              ),
                            ],
                          ),
                          // perPerson.entries
                          for (var e in state.incomePerPerson)
                            ListTile(
                              onTap: () => showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                    child: ListView.builder(
                                  itemCount: e.datas?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    var theData = e.datas![index];
                                    int total = 0;
                                    StringBuffer servicelist = StringBuffer(
                                        '${theData.namaKaryawan} : ');
                                    for (var e in theData.itemCards) {
                                      servicelist
                                          .write(cardType[e.type] + ', ');
                                      total += e.price * (e.pcsBarang);
                                    }
                                    return TileStruk(
                                      e.datas![index],
                                      servicelist,
                                      total: total,
                                    );
                                  },
                                )),
                              ),
                              title: Text(e.namaKaryawan),
                              subtitle: Text(e.totalPendapatan
                                  .numberFormat(currency: true)),
                            )
                        ],
                      ),
                    )),
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                  Theme.of(context).primaryColorDark,
                                  Theme.of(context).primaryColorDark,
                                  Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.45)
                                ])),
                                child: const Text('Pengeluaran')),
                          ),
                        ],
                      ),
                      for (var e in state.pengeluaranList)
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.namaPengeluaran.firstUpcase()),
                              Text(e.tanggal.clockOnly()),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.biaya.numberFormat(currency: true)),
                              Text('By: ${e.karyawan ?? 'Admin'}'),
                            ],
                          ),
                        )
                    ],
                  ),
                ))
              ],
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
