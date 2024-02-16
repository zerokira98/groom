import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'cubitbulanan/bulanan_cubit.dart';

class RangkumMonth extends StatelessWidget {
  const RangkumMonth({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulananCubit, BulananState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Rangkuman Bulanan'),
          ),
          body: Column(
            children: [
              Text('Income : ${state.totalPemasukan}'),
              Text('Pengeluaran : ${state.totalPengeluaran}'),
              // Text(state.incomePerHari.toString()),
              SfCartesianChart(
                title: const ChartTitle(text: 'Grafik Harian'),
                series: [
                  LineSeries(
                    xValueMapper: (datum, index) => index,
                    yValueMapper: (datum, index) => datum,
                    dataSource: state.incomePerHari,
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
