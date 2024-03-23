import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/etc/extension.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulananCubit, BulananState>(
      builder: (context, state) {
        var now = DateTime.now();
        var dateHighestIncome = DateTime(
            now.year, now.month, state.pendapatanTertinggi['day']!.toInt());
        // var pr = state.groupAndSumPengeluaran;
        // print(pr);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Rangkuman Bulanan'),
          ),
          body: Column(
            children: [
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
                          Text(state.pendapatanTertinggi['sum']!
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
                        print(datum.key);
                        return index;
                      },
                      yValueMapper: (datum, index) {
                        return (datum.value['sum']);
                      },
                      dataSource: state.groupAndSumPengeluaran.entries.toList(),
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
        );
      },
    );
  }
}
