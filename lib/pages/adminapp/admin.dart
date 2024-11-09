import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/pages/adminapp/equity/uangkeluar.dart';
import 'package:groom/pages/adminapp/karyawan.dart';
import 'package:groom/pages/adminapp/rangkuman/rangkuman.dart';
import 'package:groom/pages/adminapp/servicemenu/servicemenuedit.dart';
import 'package:groom/pages/barang/barangpage.dart';
import 'package:groom/pages/adminapp/bon/bon_page.dart';
import 'package:groom/pages/adminapp/equity/equitypage.dart';
import 'package:groom/pages/pengeluaran/pengeluaran_histori.dart';
import 'package:groom/pages/pengeluaran/pengeluaranpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:groom/pages/rangkuman/cubitharian/rangkumanharian_cubit.dart';
import 'package:weekly_date_picker/datetime_apis.dart';

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
part 'drawer_menuitems/servicemenuitems_button.dart';
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
  var pc = PageController();
  List thePages(context) {
    var curdate = DateTime.now();
    return [
      BlocProvider.value(
        value: BlocProvider.of<RangkumanDayCubit>(context)
          ..loadData({
            'tanggalStart': curdate,
            'tanggalEnd': curdate.addDays(1),
          }),
        child: const RangkumanHarian(),
      ),
      const PengeluaranPage(), //1
      const HistoriPengeluaran(),
      const BonPage(),
      const EkuitasPage(), //4
      const UangKeluarPage(),
      const KaryawanConfig(),
      const BarangPage(), //7
      BlocProvider.value(
        value: BlocProvider.of<RangkumanWeekCubit>(context)
          ..loadData({
            'tanggalStart': DateTime(curdate.year, curdate.month, curdate.day)
                .subtract(Duration(
              days: curdate.weekday,
            )),
            'tanggalEnd': DateTime(curdate.year, curdate.month, curdate.day)
                .subtract(Duration(
                  days: curdate.weekday,
                ))
                .add(const Duration(days: 7)),
          }),
        child: const RangkumanMingguan(),
      ),
      BlocProvider.value(
        value: BlocProvider.of<BulananCubit>(context)..loadData(curdate),
        child: const RangkumMonth(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Row(
      children: [
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Admin Page'),
            ),
            body: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 8.0,
                children: [
                  ///
                  const MenuDivider(title: 'Pengeluaran'),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0, left: 2.0, right: 2.0),
                    child: CatatPengeluaranButton(
                        onTap: isLandscape
                            ? () {
                                pc.animateToPage(
                                  1,
                                  curve: Curves.easeInOut,
                                  duration: Durations.long1,
                                );
                              }
                            : null),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0, left: 2.0, right: 2.0),
                    child: HistoriPengeluaranButton(
                        onTap: isLandscape
                            ? () {
                                pc.animateToPage(
                                  2,
                                  curve: Curves.easeInOut,
                                  duration: Durations.long1,
                                );
                              }
                            : null),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0, left: 2.0, right: 2.0),
                    child: BonPageButton(
                        onTap: isLandscape
                            ? () {
                                pc.animateToPage(
                                  3,
                                  curve: Curves.easeInOut,
                                  duration: Durations.long1,
                                );
                              }
                            : null),
                  ),

                  ///
                  const MenuDivider(title: 'Uang / Rekonsiliasi Bank'),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0, left: 2.0, right: 2.0),
                    child: EkuitasPageButton(
                        onTap: isLandscape
                            ? () {
                                pc.animateToPage(
                                  4,
                                  curve: Curves.easeInOut,
                                  duration: Durations.long1,
                                );
                              }
                            : null),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0, left: 2.0, right: 2.0),
                    child: UangKeluarButton(
                        onTap: isLandscape
                            ? () {
                                pc.animateToPage(
                                  5,
                                  curve: Curves.easeInOut,
                                  duration: Durations.long1,
                                );
                              }
                            : null),
                  ),

                  ///
                  const MenuDivider(title: 'Rangkuman'),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0, left: 2.0, right: 2.0),
                    child: RangkumHarianButton(
                        onTap: isLandscape
                            ? () {
                                pc.animateToPage(
                                  0,
                                  curve: Curves.easeInOut,
                                  duration: Durations.long1,
                                );
                              }
                            : null),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0, left: 2.0, right: 2.0),
                    child: RangkumMingguanButton(
                        onTap: isLandscape
                            ? () {
                                pc.animateToPage(
                                  8,
                                  curve: Curves.easeInOut,
                                  duration: Durations.long1,
                                );
                              }
                            : null),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0, left: 2.0, right: 2.0),
                    child: RangkumBulananButton(
                        onTap: isLandscape
                            ? () {
                                pc.animateToPage(
                                  9,
                                  curve: Curves.easeInOut,
                                  duration: Durations.long1,
                                );
                              }
                            : null),
                  ),

                  ///
                  const MenuDivider(title: 'etc'),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0, left: 2.0, right: 2.0),
                    child: BarangPageButton(
                        onTap: isLandscape
                            ? () {
                                pc.animateToPage(
                                  7,
                                  curve: Curves.easeInOut,
                                  duration: Durations.long1,
                                );
                              }
                            : null),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: GantiPassAdmin(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0, left: 2.0, right: 2.0),
                    child: KaryawanButton(
                        onTap: isLandscape
                            ? () {
                                pc.animateToPage(
                                  6,
                                  curve: Curves.easeInOut,
                                  duration: Durations.long1,
                                );
                              }
                            : null),
                  ),
                  const ServicemenuitemButton()
                ],
              ),
            ),
          ),
        ),
        isLandscape
            ? Container(
                color: Colors.black,
                width: 14,
                height: double.maxFinite,
              )
            : const SizedBox(),
        isLandscape
            ? Expanded(
                flex: 2,
                child: PageView.builder(
                  controller: pc,
                  allowImplicitScrolling: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => thePages(context)[index],
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

class MenuDivider extends StatelessWidget {
  final String title;
  const MenuDivider({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
