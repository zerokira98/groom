import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/karyawan_repo.dart';
import 'package:groom/etc/globalvar.dart';
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
  double imageHeight = 220.0;
  double _opacity = 0.0;
  @override
  void initState() {
    Future.delayed(
      Durations.short4,
      () {
        setState(() {
          _opacity = 1.0;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: Durations.extralong1,
                curve: Curves.bounceInOut,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.only(top: 24, bottom: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.01),
                        Colors.white,
                        Colors.white,
                        Colors.white.withOpacity(0.01),
                      ],
                      begin: const Alignment(0, -1),
                      end: const Alignment(0, 1),
                      stops: const [0.0, 0.05, 0.95, 1]),
                ),
                // color: Colors.white,
                // transformAlignment: Alignment.center,
                // transform: Matrix4.identity()..translate(imageHeight - 240),
                height: imageHeight,
                child: AnimatedOpacity(
                  duration: Durations.long1,
                  opacity: _opacity,
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
              ),
            )
          ],
        ),
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
                            RepositoryProvider.of<KaryawanRepository>(context)
                                .getAllKaryawan(kIsWeb ? true : false),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            List<DropdownMenuEntry<String?>> a = snapshot.data!
                                .map((e) => e.aktif
                                    ? DropdownMenuEntry(
                                        value: e.id, label: e.namaKaryawan)
                                    : null)
                                .nonNulls
                                .toList();
                            return DropdownMenu<String?>(
                              dropdownMenuEntries: a,
                              controller: dropdownC,
                              initialSelection: a
                                  .firstWhere(
                                    (element) =>
                                        element.label == state.karyawanName,
                                    orElse: () => const DropdownMenuEntry(
                                        value: '-1', label: 'error'),
                                  )
                                  .value,
                              onSelected: (value) {
                                BlocProvider.of<InputserviceBloc>(context).add(
                                    ChangeKaryawan(a
                                        .firstWhere((e) => e.value == value!)
                                        .label));
                              },
                            );
                          } else {
                            return const Text('error snapshot');
                          }
                        });
                  } else if (state is InputserviceInitial) {
                    return const CircularProgressIndicator();
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
        //         CupertinoPageRoute(
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
        //         CupertinoPageRoute(
        //           builder: (context) => const PlayBox(),
        //         ));
        //   },
        // ),
        const Padding(padding: EdgeInsets.all(4)),
        ListTile(
          leading: const Icon(Icons.history_sharp),
          title: const Text('Riwayat Pemasukan'),
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const RiwayatPemasukan(),
                ));
          },
        ),
        ListTile(
          leading: const Icon(Icons.note_alt),
          title: const Text('Catat Pengeluaran Toko'),
          onTap: () {
            var name = (BlocProvider.of<InputserviceBloc>(context).state
                    as InputserviceLoaded)
                .karyawanName;
            RepositoryProvider.of<KaryawanRepository>(context)
                .getAllKaryawan()
                .then((listallkaryawan) {
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
                        CupertinoPageRoute(
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
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.dangerous),
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
                      CupertinoPageRoute(
                        builder: (context) => HutangHome(namaKaryawan: name),
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
        if (debugmode)
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin'),
            onTap: () {
              InputController ic = InputController();
              final FocusNode focusNode = FocusNode();
              focusNode.requestFocus();
              showDialog<bool>(
                context: context,
                builder: (context) {
                  return KeyLock(tendigits: adminpass, title: 'Admin');
                },
              ).then((dia) {
                if (dia == null) return;
                if (dia) {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const AdminPage(),
                      ));
                }
              });
            },
          ),
      ],
    );
  }
}
