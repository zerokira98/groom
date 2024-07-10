import 'package:flutter/cupertino.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:groom/pages/rangkuman/cubitharian/rangkumanharian_cubit.dart';
import 'package:weekly_date_picker/datetime_apis.dart';

import 'drawer_menuitems/donothing_button.dart';

part 'drawer_menuitems/gantipass_admin.dart';
part 'drawer_menuitems/karyawan_button.dart';
part 'drawer_menuitems/barangpage_button.dart';
part 'drawer_menuitems/ekuitaspage_button.dart';
part 'drawer_menuitems/historipengeluaran_button.dart';
part 'drawer_menuitems/bonpage_button.dart';
part 'drawer_menuitems/catatpengeluaran_button.dart';
part 'drawer_menuitems/uangkeluar_button.dart';
part 'drawer_menuitems/rangkumanharian_button.dart';
part 'drawer_menuitems/rangkumbulan_button.dart';
part 'drawer_menuitems/rangkummingguan_button.dart';
// part 'drawer_menuitems/';
// part 'drawer_';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  static const whitestyle = TextStyle(color: Colors.white);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Widget thePage = const SizedBox();
  List thePages(context) => [
        BlocProvider.value(
          value: BlocProvider.of<RangkumanDayCubit>(context)
            ..loadData({
              'tanggalStart': DateTime.now(),
              'tanggalEnd': DateTime.now().addDays(1),
            }),
          child: const RangkumanHarian(),
        ),
        const PengeluaranPage(),
        const HistoriPengeluaran(),
        const BonPage(),
        const EkuitasPage(),
        const UangKeluarPage(),
        const KaryawanConfig(),
        const BarangPage(),
      ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 8.0,
                children: [
                  ///
                  MenuDivider(title: 'Pengeluaran'),
                  CatatPengeluaranButton(),
                  HistoriPengeluaranButton(),
                  BonPageButton(),

                  ///
                  MenuDivider(title: 'Uang / Rekonsiliasi Bank'),
                  EkuitasPageButton(),
                  UangKeluarButton(),

                  ///
                  MenuDivider(title: 'Rangkuman'),
                  RangkumHarianButton(),
                  RangkumMingguanButton(),
                  RangkumBulananButton(),

                  ///
                  MenuDivider(title: 'etc'),
                  BarangPageButton(),
                  GantiPassAdmin(),
                  KaryawanButton(),
                  DoNothingButton()
                ],
              ),
            ),
          ),
          MediaQuery.of(context).orientation == Orientation.landscape
              ? Expanded(
                  child: PageView.builder(
                    controller: PageController(),
                    allowImplicitScrolling: false,
                    itemBuilder: (context, index) => thePages(context)[index],
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

class MenuDivider extends StatelessWidget {
  final String title;
  const MenuDivider({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  child: Text(
                    title,
                    style: AdminPage.whitestyle,
                  )))
        ],
      ),
    );
  }
}
