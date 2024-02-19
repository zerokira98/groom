import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/etc/extension.dart';
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
                  Text('Total : ${fullTotal.numberFormat(currency: true)}'),
                  Text(
                      'Qris : ${state.qristotal.numberFormat(currency: true)}'),
                  Text(
                      'Pengeluaran : ${state.operasional.numberFormat(currency: true)}'),
                  Text(
                      'Total cash : ${(fullTotal - state.qristotal - state.operasional).toInt().numberFormat(currency: true)}'),
                ],
              ),
            )),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Harian'),
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
                    child: Column(
                  children: [
                    // perPerson.entries
                    for (var e in state.incomePerPerson)
                      ListTile(
                        title: Text(e.namaKaryawan),
                        subtitle: Text(e.totalPendapatan
                                .toString()
                                .numberFormat(currency: true) ??
                            'err format'),
                      )
                  ],
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