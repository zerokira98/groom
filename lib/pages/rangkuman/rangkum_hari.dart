import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/pages/rangkuman/cubitharian/rangkumanharian_cubit.dart';
import 'package:intl/intl.dart';

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
            bottomNavigationBar: BottomAppBar(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                    'Total : ${fullTotal.toString().numberFormat(currency: true)}'),
              ],
            )),
            body: Column(
              children: [
                const Text('Harian'),
                ElevatedButton(
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        firstDate: DateTime(state.tanggalStart.year - 2),
                        lastDate: now,
                        initialDate: state.tanggalStart,
                      ).then((value) {
                        if (value != null) {
                          BlocProvider.of<RangkumanDayCubit>(context).loadData({
                            'tanggalStart': value,
                            'tanggalEnd': value,
                          });
                        }
                      });
                    },
                    child: Text(
                        'Hari : ${format.format(DateTime(state.tanggalStart.year, state.tanggalStart.month, state.tanggalStart.day))}')),
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
