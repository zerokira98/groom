import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/pages/adminapp/equity/uangkeluar.dart';
import 'package:groom/pages/adminapp/karyawan.dart';
import 'package:groom/pages/adminapp/rangkuman/rangkuman.dart';
import 'package:groom/pages/barang/barangpage.dart';
import 'package:groom/pages/adminapp/bon/bon_page.dart';
import 'package:groom/pages/adminapp/equity/equitypage.dart';
import 'package:groom/pages/pengeluaran/pengeluaran_histori.dart';
import 'package:groom/pages/pengeluaran/pengeluaranpage.dart';
// import 'package:groom/pages/rangkuman/cubitharian/rangkumanharian_cubit.dart';
import 'package:weekly_date_picker/datetime_apis.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});
  static const whitestyle = TextStyle(color: Colors.white);
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
        //         debugPrint(a);
        //       },
        //       icon: const Icon(Icons.bug_report))
        // ],
      ),
      body: SingleChildScrollView(
        child: Wrap(
          spacing: 8.0,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Theme.of(context).primaryColorDark,
                            Theme.of(context).primaryColorDark,
                            Theme.of(context).primaryColorDark.withOpacity(0.45)
                          ])),
                          child: const Text(
                            'Pengeluaran',
                            style: whitestyle,
                          )))
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PengeluaranPage(),
                    ));
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit),
                  Padding(padding: EdgeInsets.only(right: 4)),
                  Text('Catat Pengeluaran'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoriPengeluaran(),
                    ));
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history),
                  Padding(padding: EdgeInsets.only(right: 4)),
                  Text('Histori Pengeluaran'),
                ],
              ),
            ),
            ElevatedButton(
              child: const Text('Bon / Piutang'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BonPage(),
                    ));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Theme.of(context).primaryColorDark,
                            Theme.of(context).primaryColorDark,
                            Theme.of(context).primaryColorDark.withOpacity(0.45)
                          ])),
                          child: const Text(
                            'Uang / Rekonsiliasi Bank',
                            style: whitestyle,
                          )))
                ],
              ),
            ),
            ElevatedButton(
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                  Text('Uang Masuk'),
                ],
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EkuitasPage(),
                    ));
              },
            ),
            ElevatedButton(
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                  Text('Uang Keluar'),
                ],
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UangKeluarPage(),
                    ));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Theme.of(context).primaryColorDark,
                            Theme.of(context).primaryColorDark,
                            Theme.of(context).primaryColorDark.withOpacity(0.45)
                          ])),
                          child: const Text(
                            'Rangkuman',
                            style: whitestyle,
                          )))
                ],
              ),
            ),
            ElevatedButton(
              child: const Row(
                children: [
                  Icon(Icons.calendar_view_day),
                  Padding(padding: EdgeInsets.only(left: 4)),
                  Text('Rangkuman Harian'),
                ],
              ),
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
            ElevatedButton(
              child: const Row(
                children: [
                  Icon(Icons.calendar_view_week),
                  Padding(padding: EdgeInsets.only(left: 4)),
                  Text('Rangkuman Mingguan'),
                ],
              ),
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
            ElevatedButton(
              child: const Row(
                children: [
                  Icon(Icons.calendar_view_month),
                  Padding(padding: EdgeInsets.only(left: 4)),
                  Text('Rangkuman Bulanan'),
                ],
              ),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Theme.of(context).primaryColorDark,
                            Theme.of(context).primaryColorDark,
                            Theme.of(context).primaryColorDark.withOpacity(0.45)
                          ])),
                          child: const Text(
                            'Etc',
                            style: whitestyle,
                          )))
                ],
              ),
            ),
            ElevatedButton(
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.supervised_user_circle),
                  Padding(padding: EdgeInsets.only(left: 4)),
                  Text('Atur Karyawan'),
                ],
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KaryawanConfig(),
                    ));
              },
            ),
            ElevatedButton(
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_grocery_store_rounded),
                  Padding(padding: EdgeInsets.only(left: 4)),
                  Text('Atur Barang'),
                ],
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarangPage(),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
