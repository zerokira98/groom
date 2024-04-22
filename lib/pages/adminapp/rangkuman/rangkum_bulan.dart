import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/etc/extension.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'cubitbulanan/bulanan_cubit.dart';

class RangkumMonth extends StatefulWidget {
  const RangkumMonth({super.key});

  @override
  State<RangkumMonth> createState() => _RangkumMonthState();
}

class _RangkumMonthState extends State<RangkumMonth> {
  bool showincome = true;
  bool showexpense = true;
  TextEditingController monthC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulananCubit, BulananState>(
      builder: (context, state) {
        if (state == BulananState.initial()) {
          return const Material(child: CircularProgressIndicator());
        }

        var thedate = state.bulan;
        monthC.text = thedate.monthName;
        var dateHighestIncome = DateTime(thedate.year, thedate.month,
            state.pendapatanTertinggi['day']!.toInt());
        var dateTotalCustomerperDay = DateTime(thedate.year, thedate.month,
            state.jumlahCustomerTertinggi['day']!.toInt());
        // var pr = state.groupAndSumPengeluaran;
        // print(pr);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Rangkuman Bulanan'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Bulan :'),
                    ),
                    Flexible(
                      child: TextField(
                        onTap: () {
                          showMonthPicker(
                                  context: context,
                                  initialDate: thedate,
                                  dismissible: true)
                              .then((value) {
                            if (value != null) {
                              BlocProvider.of<BulananCubit>(context)
                                  .loadData(value);
                            }
                          });
                        },
                        controller: monthC,
                        readOnly: true,
                      ),
                    ),
                    Expanded(child: SizedBox()),
                  ],
                ),
                Text(
                    'Income : ${state.totalPemasukan.numberFormat(currency: true)}'),
                Text(
                    'Pengeluaran : ${state.totalPengeluaran.numberFormat(currency: true)}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        height: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pendapatan tertinggi',
                              textScaler: TextScaler.linear(1.2),
                            ),
                            Text(dateHighestIncome.formatLengkap()),
                            const Expanded(child: SizedBox()),
                            Text(
                                '${state.pendapatanTertinggi['count']!.numberFormat(currency: false)}struk'),
                            Text(state.pendapatanTertinggi['sum']!
                                .numberFormat(currency: true))
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        height: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lalu lalang',
                              textScaler: TextScaler.linear(1.2),
                            ),
                            Text(
                                'Avg per open:${state.jumlahCustomerTertinggi['avg']!.numberFormat()}struk'),
                            const Expanded(child: SizedBox()),
                            Text(
                                'peak:${dateTotalCustomerperDay.weekdayName}, ${dateTotalCustomerperDay.formatDayMonth()}'),
                            // Text('No cust day:' +
                            //     state.jumlahCustomerTertinggi['emptyDays']!
                            //         .numberFormat()),
                            Text(
                                '${state.jumlahCustomerTertinggi['count']!.numberFormat()}struk'),
                            Text(state.jumlahCustomerTertinggi['sum']!
                                .numberFormat(currency: true))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Text(state.incomePerHari.toString()),
                SfCartesianChart(
                  tooltipBehavior: TooltipBehavior(enable: true),
                  zoomPanBehavior: ZoomPanBehavior(
                      zoomMode: ZoomMode.x,
                      enableDoubleTapZooming: true,
                      enablePinching: true,
                      enablePanning: true),
                  title: const ChartTitle(text: 'Grafik Income Harian'),
                  series: [
                    if (showincome && state.incomePerHari.isNotEmpty)
                      ColumnSeries(
                        animationDuration: 750,
                        color: Colors.red,
                        // markerSettings: MarkerSettings(isVisible: true),
                        // dataLabelMapper: (datum, index) => index.toString(),
                        // dataLabelSettings: DataLabelSettings(isVisible: true),
                        xValueMapper: (datum, index) => index,
                        yValueMapper: (datum, index) => datum,
                        dataSource: state.incomePerHari,
                      ),
                    if (showexpense && state.groupAndSumPengeluaran.isNotEmpty)
                      ColumnSeries(
                        color: Colors.blue,
                        xValueMapper: (datum, index) {
                          return index;
                        },
                        yValueMapper: (datum, index) {
                          return (datum.value['sum']);
                        },
                        dataSource:
                            state.groupAndSumPengeluaran.entries.toList(),
                      )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Color : '),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.trending_neutral,
                                color: Colors.red,
                              ),
                              const Text('Income per hari'),
                              Checkbox(
                                value: showincome,
                                onChanged: (value) => setState(() {
                                  showincome = value ?? false;
                                }),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.trending_neutral,
                                color: Colors.blue,
                              ),
                              const Text('Pengeluaran per hari'),
                              Checkbox(
                                value: showexpense,
                                onChanged: (value) => setState(() {
                                  showexpense = value ?? false;
                                }),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
