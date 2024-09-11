import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/karyawan_repo.dart';
import 'package:groom/etc/globalvar.dart';
import 'package:groom/etc/lockscreen_keylock.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAppbar extends StatelessWidget {
  final TextEditingController dropdownC = TextEditingController();
  HomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(24)),
          gradient: LinearGradient(colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColorDark,
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      padding: const EdgeInsets.all(8.0).add(EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top, bottom: 8)),
      child: Row(
        children: [
          MediaQuery.of(context).orientation == Orientation.portrait
              ? IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(Icons.menu))
              : const SizedBox(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Karyawan : ',
                    style: TextStyle(color: Colors.white),
                  ),
                  BlocBuilder<InputserviceBloc, InputserviceState>(
                    builder: (context, state) {
                      if (state is InputserviceLoaded) {
                        dropdownC.text = state.karyawanName;
                        return FutureBuilder(
                            future: RepositoryProvider.of<KaryawanRepository>(
                                    context)
                                .getAllKaryawan(kIsWeb ? true : false),
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                List<DropdownMenuEntry<String?>> a = snapshot
                                    .data!
                                    .map((e) => e.aktif
                                        ? DropdownMenuEntry(
                                            value: e.id, label: e.namaKaryawan)
                                        : null)
                                    .nonNulls
                                    .toList();
                                return DropdownMenu<String?>(
                                  inputDecorationTheme:
                                      const InputDecorationTheme(
                                    outlineBorder:
                                        BorderSide(color: Colors.red),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 2, color: Colors.red)),
                                  ),
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                  menuStyle: const MenuStyle(),
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
                                    BlocProvider.of<InputserviceBloc>(context)
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
                        return const CircularProgressIndicator.adaptive();
                      }
                    },
                  )
                ],
              ),
            ),
          ),
          BlocBuilder<InputserviceBloc, InputserviceState>(
            builder: (context, state) {
              if (state is InputserviceLoaded) {
                // debugPrint(state.karyawanName);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${state.karyawanName} ',
                      style: const TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                        onLongPress: () async {
                          SharedPreferences.getInstance().then((spref) {
                            showDialog(
                              context: context,
                              builder: (context) => KeyLock(
                                  tendigits:
                                      spref.getString('adminpass') ?? adminpass,
                                  title: 'Admin'),
                            ).then((value) {
                              if (value != null && value) {
                                showDatePicker(
                                        context: context,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now())
                                    .then((v) {
                                  if (v != null) {
                                    BlocProvider.of<InputserviceBloc>(context)
                                        .add(ChangeTanggal(v));
                                  }
                                });
                              }
                            });
                          });
                        },
                        child: Text(
                          DateFormat('dd/M/yyyy hh:mm', 'id_ID')
                              .format(state.tanggal)
                              .toString(),
                          style: const TextStyle(color: Colors.white),
                        ))
                  ],
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}
