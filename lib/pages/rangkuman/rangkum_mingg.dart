import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/itemcard_mdl.dart';
import 'package:groom/pages/rangkuman/cubitmingguan/rangkumanmingg_cubit.dart';

class RangkumanMingguan extends StatelessWidget {
  const RangkumanMingguan({super.key});

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();

    return BlocBuilder<RangkumanWeekCubit, RangkumanWeekState>(
      builder: (context, state) {
        if (state is RangkumanWeekLoaded) {
          List<double> perpersonTotal = [];
          // if (state.groupBy.index == 0) {
          for (var i = 0; i < state.dataPerPerson.length; i++) {
            var countPrice = 0.0;
            state.dataPerPerson[i].itemCards.forEach((e) {
              print('${e.type} ${e.price}');
              // print(e.price);
              countPrice += e.price;
            });
            perpersonTotal.add(countPrice);
            // }
          }
          // print(state.dataPerPerson.length);
          return Column(children: [
            Row(
              children: [
                const Text('Order by person?'),
                Checkbox(
                  value: state.groupBy == GroupBy.namaKayrawan,
                  onChanged: (value) {
                    var sd = state.tanggalStart;
                    var ed = state.tanggalEnd;
                    if (value!) {
                      BlocProvider.of<RangkumanWeekCubit>(context).loadData({
                        'tanggalStart': sd,
                        'tanggalEnd': ed,
                        'groupBy': GroupBy.namaKayrawan
                      });
                    } else {
                      BlocProvider.of<RangkumanWeekCubit>(context).loadData({
                        'tanggalStart': sd,
                        'tanggalEnd': ed,
                      });
                    }
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  firstDate: DateTime(now.year - 5),
                  lastDate: now,
                ).then((value) {
                  if (value != null) {
                    var ts = DateTime(value.year, value.month, value.day)
                        .subtract(Duration(days: value.weekday));
                    var te = ts.add(const Duration(days: 7));
                    BlocProvider.of<RangkumanWeekCubit>(context).loadData({
                      'tanggalStart': ts,
                      'tanggalEnd': te,
                    });
                  }
                });
              },
              child: Text(
                  'Week ${state.tanggalStart.formatLengkap()}-${state.tanggalEnd.formatLengkap()}'),
            ),
            if (state.groupBy == GroupBy.date)
              Expanded(
                  child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  var totalHarian = 0;
                  for (var ew in state.daily[index + 1].values.first) {
                    totalHarian += ew.totalPendapatan;
                  }
                  var separatorStyle = TextStyle(color: Colors.white);
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                          Theme.of(context).primaryColorDark,
                          Theme.of(context).primaryColorDark,
                          Theme.of(context).primaryColorDark.withOpacity(0.45)
                        ])),
                        child: Row(
                          children: [
                            Text(
                              state.daily[index + 1].keys.first.formatLengkap(),
                              style: separatorStyle,
                            ),
                            const Expanded(child: SizedBox()),
                            Text('Total Hari ini:', style: separatorStyle),
                            Text(
                                totalHarian
                                        .toString()
                                        .numberFormat(currency: true) ??
                                    'err parse',
                                style: separatorStyle)
                          ],
                        ),
                      ),
                      for (var z in state.daily[index + 1].values.first)
                        ListTile(
                          title: Text(z.namaKaryawan),
                          subtitle: Text(z.totalPendapatan
                                  .toString()
                                  .numberFormat(currency: true) ??
                              'err format'),
                        ),
                    ],
                  );
                },
              )),
            if (state.groupBy == GroupBy.namaKayrawan)
              Expanded(
                  child: ListView.builder(
                itemCount: state.dataPerPerson.length,
                itemBuilder: (context, index) {
                  double cutPercentage(int type) => switch (type) {
                        0 => 0.48,
                        1 => 0.5,
                        2 => 0.5,
                        3 => 0.1,
                        int() => 1,
                      };
                  double tot = 0;
                  for (var awo in state.dataPerPerson[index].itemCards) {
                    tot += awo.price * cutPercentage(awo.type);
                  }
                  return ListTile(
                    title: Text(state.dataPerPerson[index].namaKaryawan),
                    subtitle: Row(
                      children: [
                        Text(perpersonTotal[index].toString()),
                        Expanded(child: SizedBox()),
                        Text('Expected payment: '),
                        Text(tot
                                .toInt()
                                .toString()
                                .numberFormat(currency: true) ??
                            'err pars'),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                      state.dataPerPerson[index].namaKaryawan),
                                ),
                                // for (var awo
                                //     in state.dataPerPerson[index].itemCards)
                                //   Row(
                                //     children: [
                                //       Text(cardType[awo.type]),
                                //       Padding(padding: EdgeInsets.all(8)),
                                //       Text(awo.price.toString()),
                                //       Padding(padding: EdgeInsets.all(8)),
                                //       Text(
                                //           (cutPercentage(awo.type)).toString()),
                                //       Padding(padding: EdgeInsets.all(8)),
                                //       Text((awo.price * cutPercentage(awo.type))
                                //           .toString()),
                                //     ],
                                //   ),
                                Table(
                                  border: TableBorder.all(),
                                  children: [
                                    for (var awo
                                        in state.dataPerPerson[index].itemCards)
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Text(cardType[awo.type]),
                                        ),
                                        Text(
                                          awo.price.toString(),
                                          textAlign: TextAlign.end,
                                        ),
                                        Text(' ' +
                                            cutPercentage(awo.type).toString()),
                                        Text(
                                          (awo.price * cutPercentage(awo.type))
                                              .toString(),
                                          textAlign: TextAlign.end,
                                        ),
                                      ])
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Text('Expected payment: '),
                                      Expanded(child: SizedBox()),
                                      Text(
                                          ' ${tot.toInt().toString().numberFormat(currency: true)}'),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              )),
            Text(
                'Total income: ${state.totalKotor.toString().numberFormat(currency: true)}'),
            Text(
                'Income-bagihasil: ${state.totalBagiHasil.toString().numberFormat()}'),
            const Text('Pengeluaran: Rp.5XX.000+bon'),
          ]);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
