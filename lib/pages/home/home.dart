import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/karyawan_repo.dart';
import 'package:groom/etc/globalvar.dart';
import 'package:groom/etc/lockscreen_keylock.dart';
import 'package:groom/pages/home/drawer.dart';
import 'package:groom/etc/extension.dart';

import 'package:groom/pages/home/itemcard.dart';
import 'package:groom/model/model.dart';
import 'package:groom/pages/home/riwayat_pemasukan.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final TextEditingController dropdownC = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 48,
      drawer: const SideDrawer(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: FloatingButton(formstate: formKey),
      // bottomNavigationBar: Padding(
      //   padding: MediaQuery.of(context).viewInsets,
      //   child:
      // ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kIsWeb &&
              MediaQuery.of(context).orientation == Orientation.portrait)
            Builder(builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.view_list_sharp),
              );
            }),
          if (kIsWeb &&
              MediaQuery.of(context).orientation == Orientation.landscape)
            const SideDrawer(),
          Expanded(
            child: BlocListener<InputserviceBloc, InputserviceState>(
              listenWhen: (pre, cur) =>
                  (pre is InputserviceLoaded) && (cur is InputserviceLoaded),
              listener: (context, state) {
                if (state is InputserviceLoaded) {
                  if (state.success != null) {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const RiwayatPemasukan(),
                        ));
                    BlocProvider.of<InputserviceBloc>(context).add(Initiate());
                  } else if (state.err != null) {
                    Flushbar(
                      message: state.err,
                      duration: const Duration(seconds: 2),
                      animationDuration: Durations.long1,
                    ).show(context);
                  }
                }
              },
              child: Stack(
                children: [
                  OfflineBuilder(
                    errorBuilder: (context) => const Text('err no connection'),
                    connectivityBuilder: (context, value, child) => Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedPositioned(
                          duration: Durations.extralong4,
                          curve:
                              const Interval(0.5, 1.0, curve: Curves.easeInOut),
                          height: value != ConnectivityResult.none ? 0 : 24,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            color: value != ConnectivityResult.none
                                ? const Color(0xFF00EE44)
                                : const Color(0xFFEE4400),
                            child: Center(
                              child: Text(value != ConnectivityResult.none
                                  ? 'ONLINE'
                                  : 'OFFLINE MODE'),
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: Durations.extralong4,
                          curve:
                              const Interval(0.5, 1.0, curve: Curves.easeInOut),
                          padding: EdgeInsets.only(
                              top: value != ConnectivityResult.none
                                  ? 0.0
                                  : 26.0),
                          child: child,
                        )
                      ],
                    ),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        BlocProvider.of<InputserviceBloc>(context)
                            .add(Initiate());
                        return Future.delayed(Durations.extralong4, () => true);
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(24)),
                                  gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).primaryColor,
                                        Theme.of(context).primaryColorDark,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter)),
                              padding: const EdgeInsets.all(8.0).add(
                                  EdgeInsets.only(
                                      top: MediaQuery.of(context)
                                          .viewPadding
                                          .top,
                                      bottom: 8)),
                              child: Row(
                                children: [
                                  const Text(
                                    'Karyawan : ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Expanded(child: BlocBuilder<InputserviceBloc,
                                      InputserviceState>(
                                    builder: (context, state) {
                                      if (state is InputserviceLoaded) {
                                        dropdownC.text = state.karyawanName;
                                        return FutureBuilder(
                                            future: RepositoryProvider.of<
                                                    KaryawanRepository>(context)
                                                .getAllKaryawan(
                                                    kIsWeb ? true : false),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data!.isNotEmpty) {
                                                List<
                                                    DropdownMenuEntry<
                                                        String?>> a = snapshot
                                                    .data!
                                                    .map((e) => e.aktif
                                                        ? DropdownMenuEntry(
                                                            value: e.id,
                                                            label:
                                                                e.namaKaryawan)
                                                        : null)
                                                    .nonNulls
                                                    .toList();
                                                return DropdownMenu<String?>(
                                                  inputDecorationTheme:
                                                      const InputDecorationTheme(
                                                    outlineBorder: BorderSide(
                                                        color: Colors.red),
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            width: 2,
                                                            color: Colors.red)),
                                                  ),
                                                  textStyle: const TextStyle(
                                                      color: Colors.white),
                                                  menuStyle: const MenuStyle(),
                                                  dropdownMenuEntries: a,
                                                  controller: dropdownC,
                                                  initialSelection: a
                                                      .firstWhere(
                                                        (element) =>
                                                            element.label ==
                                                            state.karyawanName,
                                                        orElse: () =>
                                                            const DropdownMenuEntry(
                                                                value: '-1',
                                                                label: 'error'),
                                                      )
                                                      .value,
                                                  onSelected: (value) {
                                                    BlocProvider.of<
                                                                InputserviceBloc>(
                                                            context)
                                                        .add(ChangeKaryawan(a
                                                            .firstWhere((e) =>
                                                                e.value ==
                                                                value!)
                                                            .label));
                                                  },
                                                );
                                              } else {
                                                return const Text(
                                                    'error snapshot');
                                              }
                                            });
                                      } else {
                                        return const CircularProgressIndicator
                                            .adaptive();
                                      }
                                    },
                                  )),
                                  BlocBuilder<InputserviceBloc,
                                      InputserviceState>(
                                    builder: (context, state) {
                                      if (state is InputserviceLoaded) {
                                        // debugPrint(state.karyawanName);
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${state.karyawanName} ',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            GestureDetector(
                                                onLongPress: () async {
                                                  SharedPreferences
                                                          .getInstance()
                                                      .then((spref) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => KeyLock(
                                                          tendigits:
                                                              spref.getString(
                                                                      'adminpass') ??
                                                                  adminpass,
                                                          title: 'Admin'),
                                                    ).then((value) {
                                                      if (value != null &&
                                                          value) {
                                                        showDatePicker(
                                                                context:
                                                                    context,
                                                                firstDate:
                                                                    DateTime(
                                                                        2020),
                                                                lastDate:
                                                                    DateTime
                                                                        .now())
                                                            .then((v) {
                                                          if (v != null) {
                                                            BlocProvider.of<
                                                                        InputserviceBloc>(
                                                                    context)
                                                                .add(
                                                                    ChangeTanggal(
                                                                        v));
                                                          }
                                                        });
                                                      }
                                                    });
                                                  });
                                                },
                                                child: Text(
                                                  DateFormat('dd/M/yyyy hh:mm',
                                                          'id_ID')
                                                      .format(state.tanggal)
                                                      .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ))
                                          ],
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(6)),
                            BlocBuilder<InputserviceBloc, InputserviceState>(
                              builder: (context, state) {
                                if (state is InputserviceLoaded) {
                                  return Form(
                                    key: formKey,
                                    child: Column(
                                      children: [
                                        for (var a = 0;
                                            a < state.itemCards.length;
                                            a++)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Stack(children: [
                                              ItemCard(
                                                  data: state.itemCards[a]),
                                              Positioned(
                                                  child: Card(
                                                      elevation: 2,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Text('${a + 1}'),
                                                      ))),
                                            ]),
                                          ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                            // ItemCard(),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16.0),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          BlocProvider.of<InputserviceBloc>(
                                                  context)
                                              .add(AddCard());
                                        },
                                        child: const Text('+')),
                                  ),
                                )
                              ],
                            ),
                            const Padding(padding: EdgeInsets.all(12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                      child: Row(
                        children: [
                          BlocBuilder<InputserviceBloc, InputserviceState>(
                            builder: (context, state) {
                              if (state is InputserviceLoaded) {
                                var total = 0;
                                for (var element in state.itemCards) {
                                  total += element.price * (element.pcsBarang);
                                }
                                return Text(
                                  'Total : ${total.toString().numberFormat(currency: true)}',
                                  textScaler: const TextScaler.linear(1.5),
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingButton extends StatelessWidget {
  FloatingButton({super.key, required this.formstate});
  final GlobalKey<FormState> formstate;
  final TextEditingController uangCustomer = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InputserviceBloc, InputserviceState>(
      builder: (context, state) {
        if (state is InputserviceLoaded) {
          return FloatingActionButton(
              child: const Icon(Icons.upload),
              onPressed: () {
                if (state.itemCards.isNotEmpty) {
                  if ((formstate.currentState?.validate() ?? false) == false) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Ada kesalahan pengisian data.')));
                    return;
                  }
                  num totalpembayaran = 0;
                  for (var e in state.itemCards) {
                    totalpembayaran += e.pcsBarang * e.price;
                  }
                  uangCustomer.text = totalpembayaran.toString();
                  showCupertinoDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) => AlertDialog(
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    var karname =
                                        (BlocProvider.of<InputserviceBloc>(
                                                    context)
                                                .state as InputserviceLoaded)
                                            .karyawanName;
                                    RepositoryProvider.of<KaryawanRepository>(
                                            context)
                                        .getAllKaryawan()
                                        .then((value) => value
                                            .firstWhere((element) =>
                                                element.namaKaryawan == karname)
                                            .password)
                                        .then((pass) {
                                      if (pass != null) {
                                        showDialog<bool>(
                                          context: context,
                                          builder: (context) => KeyLock(
                                            tendigits: pass,
                                            title: karname,
                                          ),
                                        ).then((correct) {
                                          if (correct != null && correct) {
                                            Navigator.pop(context);
                                            BlocProvider.of<InputserviceBloc>(
                                                    context)
                                                .add(SubmitToDB());
                                          } else {}
                                        });
                                      } else {
                                        Flushbar(
                                          message: 'Set user pass',
                                          duration: const Duration(seconds: 2),
                                          animationDuration: Durations.long1,
                                        ).show(context);
                                      }
                                    });
                                  },
                                  child: const Text('Submit')),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Batal'))
                            ],
                            title: Text(state.karyawanName),
                            content: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Table(
                                          columnWidths: const {
                                            1: IntrinsicColumnWidth()
                                          },
                                          border: TableBorder.all(),
                                          children: [
                                            for (var awo in state.itemCards)
                                              TableRow(children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Column(
                                                    children: [
                                                      Text(cardType[awo.type]),
                                                      if (awo.type == 3)
                                                        Text(
                                                            ' (${awo.namaBarang} (${awo.pcsBarang}x))'),
                                                      if (awo.type == 4)
                                                        Text(
                                                            ' (${awo.namaBarang})')
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: Text(
                                                    (awo.price * awo.pcsBarang)
                                                            .toString()
                                                            .numberFormat(
                                                                currency:
                                                                    true) ??
                                                        'err parse',
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
                                              ]),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.all(4)),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total :',
                                      textScaler: TextScaler.linear(1.25),
                                    ),
                                    Text(
                                      totalpembayaran.numberFormat(
                                          currency: true),
                                      textScaler: const TextScaler.linear(1.25),
                                    ),
                                  ],
                                ),
                                BlocBuilder<InputserviceBloc,
                                    InputserviceState>(
                                  builder: (context, state) {
                                    if (state is InputserviceLoaded) {
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              DropdownButton(
                                                value: state.tipePembayaran,
                                                items: const [
                                                  DropdownMenuItem(
                                                      value:
                                                          TipePembayaran.cash,
                                                      child: Text('Cash')),
                                                  DropdownMenuItem(
                                                      value:
                                                          TipePembayaran.qris,
                                                      child: Text('Qris'))
                                                ],
                                                onChanged: (value) {
                                                  BlocProvider.of<
                                                              InputserviceBloc>(
                                                          context)
                                                      .add(ChangeTipePembayaran(
                                                          type: value ??
                                                              TipePembayaran
                                                                  .cash));
                                                },
                                              ),
                                            ],
                                          ),
                                          if (state.tipePembayaran.index == 1)
                                            StatefulBuilder(
                                                builder: (context, setstate) {
                                              var uangcust = (int.tryParse(
                                                      uangCustomer.text) ??
                                                  0);
                                              var kurangan =
                                                  totalpembayaran - uangcust;
                                              var theteks = '0';
                                              if (uangcust == 0) {
                                                theteks = '0';
                                              } else if (kurangan > 0) {
                                                theteks = 'uang kurang';
                                              } else if (kurangan < 0) {
                                                theteks =
                                                    (kurangan * -1).toString();
                                              }
                                              return Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          controller:
                                                              uangCustomer,
                                                          onTap: () => uangCustomer
                                                                  .selection =
                                                              TextSelection(
                                                                  baseOffset: 0,
                                                                  extentOffset:
                                                                      uangCustomer
                                                                          .value
                                                                          .text
                                                                          .length),
                                                          onChanged: (value) {
                                                            setstate(() {});
                                                          },
                                                          decoration:
                                                              const InputDecoration(
                                                                  label: Text(
                                                                      'Uang')),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Text('Kembalian : Rp$theteks')
                                                ],
                                              );
                                            }),
                                        ],
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ));
                }
              });
        }
        return const SizedBox();
      },
    );
  }
}
