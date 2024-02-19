import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/etc/lockscreen_keylock.dart';

import 'package:groom/pages/adminapp/admin.dart';
import 'package:groom/pages/home/pengeluaran_home.dart';
import 'package:groom/pages/home/utang_home.dart';

// import 'package:groom/pages/rangkuman/cubitharian/rangkumanharian_cubit.dart';
import 'package:groom/pages/home/riwayat_pemasukan.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  final TextEditingController dropdownC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 14, bottom: 4),
                  color: Colors.white,
                  height: 240,
                  child: Image.asset(
                    'img/logo.jpg',
                    fit: BoxFit.contain,
                    // child: Center(
                    //   child: Transform.rotate(
                    //     angle: -0.4,
                    //     child: const Text(
                    //       'Groom \nBarberShop',
                    //       style: TextStyle(fontSize: 48),
                    //     ),
                    //   ),
                    // ),
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Text('Karyawan : '),
                      BlocBuilder<InputserviceBloc, InputserviceState>(
                        builder: (context, state) {
                          if (state is InputserviceLoaded) {
                            dropdownC.text = state.karyawanName;
                            return FutureBuilder(
                                future:
                                    RepositoryProvider.of<KaryawanRepository>(
                                            context)
                                        .getAllKaryawan(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data!.isNotEmpty) {
                                    List<DropdownMenuEntry<int>> a = snapshot
                                        .data!
                                        .map((e) => e.aktif
                                            ? DropdownMenuEntry(
                                                value: e.id,
                                                label: e.namaKaryawan)
                                            : null)
                                        .nonNulls
                                        .toList();
                                    return DropdownMenu<int>(
                                      dropdownMenuEntries: a,
                                      controller: dropdownC,
                                      initialSelection: a
                                          .firstWhere(
                                            (element) =>
                                                element.label ==
                                                state.karyawanName,
                                            orElse: () =>
                                                const DropdownMenuEntry(
                                                    value: -1, label: 'error'),
                                          )
                                          .value,
                                      onSelected: (value) {
                                        BlocProvider.of<InputserviceBloc>(
                                                context)
                                            .add(ChangeKaryawan(a
                                                .firstWhere(
                                                    (e) => e.value == value!)
                                                .label));
                                      },
                                    );
                                  } else {
                                    return const Text('error snapshot');
                                  }
                                });
                          } else {
                            return const Text('error');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // ListTile(
                //   title: const Text('Harian'),
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => BlocProvider.value(
                //             value: BlocProvider.of<RangkumanDayCubit>(context)
                //               ..loadData({
                //                 'tanggalStart': DateTime.now(),
                //                 'tanggalEnd': DateTime.now().addDays(1),
                //               }),
                //             child: const RangkumanHarian(),
                //           ),
                //         ));
                //   },
                // ),
                // ListTile(
                //   title: const Text('Riwayat pley'),
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => const PlayBox(),
                //         ));
                //   },
                // ),
                const Padding(padding: EdgeInsets.all(4)),
                ListTile(
                  title: const Text('Riwayat Pemasukan'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RiwayatPemasukan(),
                        ));
                  },
                ),
                ListTile(
                  title: const Text('Catat Pengeluaran Toko'),
                  onTap: () async {
                    var name = (BlocProvider.of<InputserviceBloc>(context).state
                            as InputserviceLoaded)
                        .karyawanName;
                    var listallkaryawan =
                        await RepositoryProvider.of<KaryawanRepository>(context)
                            .getAllKaryawan();
                    var pass = listallkaryawan
                        .firstWhere(
                          (element) => element.namaKaryawan == name,
                        )
                        .password;
                    if (pass != null) {
                      showDialog<bool?>(
                        context: context,
                        builder: (context) => KeyLock(
                          tendigits: pass,
                          title: 'Karyawan: $name',
                        ),
                      ).then((value) {
                        if (value != null && value) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PengeluaranHome(),
                              ));
                        } else {
                          // Navigator.pop(context);
                        }
                      });
                    } else {
                      Flushbar(
                        message: 'no password is set',
                        duration: const Duration(seconds: 3),
                        animationDuration: Durations.long1,
                      ).show(context);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Tombol Berbahaya'),
                  onTap: () async {
                    var name = (BlocProvider.of<InputserviceBloc>(context).state
                            as InputserviceLoaded)
                        .karyawanName;
                    var listallkaryawan =
                        await RepositoryProvider.of<KaryawanRepository>(context)
                            .getAllKaryawan();
                    var pass = listallkaryawan
                        .firstWhere(
                          (element) => element.namaKaryawan == name,
                        )
                        .password;
                    if (pass != null) {
                      showDialog<bool?>(
                        context: context,
                        builder: (context) => KeyLock(
                          tendigits: pass,
                          title: 'Karyawan: $name',
                        ),
                      ).then((value) {
                        if (value != null && value) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HutangHome(namaKaryawan: name),
                              ));
                        } else {
                          // Navigator.pop(context);
                        }
                      });
                    } else {
                      Flushbar(
                        message: 'no password is set',
                        duration: const Duration(seconds: 3),
                        animationDuration: Durations.long1,
                      ).show(context);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Admin'),
                  onTap: () async {
                    InputController ic = InputController();
                    final FocusNode focusNode = FocusNode();
                    focusNode.requestFocus();
                    bool dia = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return KeyLock(tendigits: '12340', title: 'Admin');
                          },
                        ) ??
                        false;
                    if (dia) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminPage(),
                          ));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
