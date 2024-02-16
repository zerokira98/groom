import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/pages/adminapp/karyawan.dart';
import 'package:groom/pages/adminapp/rangkuman/cubitbulanan/bulanan_cubit.dart';
import 'package:groom/pages/adminapp/rangkuman/cubitharian/rangkumanharian_cubit.dart';
import 'package:groom/pages/adminapp/rangkuman/cubitmingguan/rangkumanmingg_cubit.dart';
import 'package:groom/pages/adminapp/rangkuman/rangkum_bulan.dart';
import 'package:groom/pages/adminapp/rangkuman/rangkum_hari.dart';
import 'package:groom/pages/adminapp/rangkuman/rangkum_mingg.dart';
import 'package:groom/pages/bon/bon_page.dart';
import 'package:groom/pages/equity/equitypage.dart';
import 'package:groom/pages/pengeluaran/pengeluaran_histori.dart';
import 'package:groom/pages/pengeluaran/pengeluaranpage.dart';
// import 'package:groom/pages/rangkuman/cubitharian/rangkumanharian_cubit.dart';
import 'package:weekly_date_picker/datetime_apis.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
        // actions: [
        //   IconButton(
        //       onPressed: () async {
        //         var a = await RepositoryProvider.of<KaryawanRepository>(context)
        //             .getAllKaryawan();
        //         print(a);
        //       },
        //       icon: const Icon(Icons.bug_report))
        // ],
      ),
      body: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                          Theme.of(context).primaryColorDark,
                          Theme.of(context).primaryColorDark,
                          Theme.of(context).primaryColorDark.withOpacity(0.45)
                        ])),
                        child: Text('Pengeluaran')))
              ],
            ),
          ),
          Card(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PengeluaranPage(),
                    ));
              },
              child: const Text('Catat Pengeluaran'),
            ),
          ),
          Card(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoriPengeluaran(),
                    ));
              },
              child: const Text('Histori Pengeluaran'),
            ),
          ),
          Card(
            child: ElevatedButton(
              child: const Text('Bon / Piutang'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BonPage(),
                    ));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                          Theme.of(context).primaryColorDark,
                          Theme.of(context).primaryColorDark,
                          Theme.of(context).primaryColorDark.withOpacity(0.45)
                        ])),
                        child: Text('Masuk')))
              ],
            ),
          ),
          Card(
            child: ElevatedButton(
              child: const Text('Uang Masuk'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EkuitasPage(),
                    ));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                          Theme.of(context).primaryColorDark,
                          Theme.of(context).primaryColorDark,
                          Theme.of(context).primaryColorDark.withOpacity(0.45)
                        ])),
                        child: Text('Rangkuman')))
              ],
            ),
          ),
          Card(
            child: ElevatedButton(
              child: const Text('Rangkuman Bulanan'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: BlocProvider.of<BulananCubit>(context)
                          ..loadData(DateTime.now()),
                        child: const RangkumMonth(),
                      ),
                    ));
              },
            ),
          ),
          Card(
            child: ElevatedButton(
              child: const Text('Rangkuman Harian'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: BlocProvider.of<RangkumanDayCubit>(context)
                          ..loadData({
                            'tanggalStart': DateTime.now(),
                            'tanggalEnd': DateTime.now().addDays(1),
                          }),
                        child: const RangkumanHarian(),
                      ),
                    ));
              },
            ),
          ),
          Card(
            child: ElevatedButton(
              child: const Text('Rangkuman Mingguan'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: BlocProvider.of<RangkumanWeekCubit>(context)
                        ..loadData({
                          'tanggalStart': DateTime(DateTime.now().year,
                                  DateTime.now().month, DateTime.now().day)
                              .subtract(Duration(
                            days: DateTime.now().weekday,
                          )),
                          'tanggalEnd': DateTime(DateTime.now().year,
                                  DateTime.now().month, DateTime.now().day)
                              .subtract(Duration(
                                days: DateTime.now().weekday,
                              ))
                              .add(const Duration(days: 7)),
                        }),
                      child: const RangkumanMingguan(),
                      // ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                          Theme.of(context).primaryColorDark,
                          Theme.of(context).primaryColorDark,
                          Theme.of(context).primaryColorDark.withOpacity(0.45)
                        ])),
                        child: Text('Etc')))
              ],
            ),
          ),
          Card(
            child: ElevatedButton(
              child: const Text('Atur Karyawan'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KaryawanConfig(),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
