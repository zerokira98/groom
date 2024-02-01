import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/pages/adminapp/admin.dart';

import 'package:groom/pages/rangkuman/cubitharian/rangkumanharian_cubit.dart';
import 'package:groom/pages/rangkuman/cubitmingguan/rangkumanmingg_cubit.dart';
import 'package:groom/pages/rangkuman/rangkuman.dart';
import 'package:groom/pages/riwayat_pemasukan.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.red,
                  height: 240,
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.4,
                      child: const Text(
                        'Groom \nBarberShop',
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                const ListTile(
                  title: Text('Pemasukan'),
                ),
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
                  title: const Text('Admin'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminPage(),
                        ));
                  },
                ),
                const ListTile(
                  title: Text('Pengeluaran'),
                ),
                ListTile(
                  title: const Text('Rangkuman'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => RangkumanDayCubit(
                                    RepositoryProvider.of<PemasukanRepository>(
                                        context))
                                  ..loadData({
                                    'tanggalStart': DateTime.now(),
                                    'tanggalEnd': DateTime.now(),
                                  }),
                              ),
                              BlocProvider(
                                create: (context) => RangkumanWeekCubit(
                                    RepositoryProvider.of<PemasukanRepository>(
                                        context))
                                  ..loadData({
                                    'tanggalStart': DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day)
                                        .subtract(Duration(
                                      days: DateTime.now().weekday,
                                    )),
                                    'tanggalEnd': DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day)
                                        .subtract(Duration(
                                          days: DateTime.now().weekday,
                                        ))
                                        .add(const Duration(days: 7)),
                                  }),
                              ),
                            ],
                            child: Rangkuman(),
                          ),
                        ));
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
