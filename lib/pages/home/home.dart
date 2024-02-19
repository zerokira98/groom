import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/etc/lockscreen_keylock.dart';
import 'package:groom/pages/home/drawer.dart';
import 'package:groom/etc/extension.dart';

import 'package:groom/pages/home/itemcard.dart';
import 'package:groom/model/model.dart';
import 'package:groom/pages/home/riwayat_pemasukan.dart';
import 'package:intl/intl.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final TextEditingController dropdownC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocListener<InputserviceBloc, InputserviceState>(
          listenWhen: (pre, cur) =>
              (pre is InputserviceLoaded) && (cur is InputserviceLoaded),
          listener: (context, state) {
            if (state is InputserviceLoaded) {
              if (state.success != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RiwayatPemasukan(),
                    ));
                BlocProvider.of<InputserviceBloc>(context).add(Initiate());
              }
            }
          },
          child: const Text('Groom'),
        ),
        // actions: [
        //   IconButton(
        //       onPressed: () async {
        //         print(await RepositoryProvider.of<PemasukanRepository>(context)
        //             .getAllStruk());
        //       },
        //       icon: const Icon(Icons.bug_report))
        // ],
      ),
      drawer: const SideDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: FloatingButton(),
      bottomNavigationBar: BottomAppBar(
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
                    textScaler: TextScaler.linear(1.5),
                  );
                } else {
                  return const SizedBox();
                }
              },
            )
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<InputserviceBloc>(context).add(Initiate());
          return Future.delayed(Durations.extralong4, () => true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Karyawan : '),
                  Expanded(
                      child: BlocBuilder<InputserviceBloc, InputserviceState>(
                    builder: (context, state) {
                      if (state is InputserviceLoaded) {
                        dropdownC.text = state.karyawanName;
                        return FutureBuilder(
                            future: RepositoryProvider.of<KaryawanRepository>(
                                    context)
                                .getAllKaryawan(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                List<DropdownMenuEntry<int>> a = snapshot.data!
                                    .map((e) => e.aktif
                                        ? DropdownMenuEntry(
                                            value: e.id, label: e.namaKaryawan)
                                        : null)
                                    .nonNulls
                                    .toList();
                                return DropdownMenu<int>(
                                  dropdownMenuEntries: a,
                                  controller: dropdownC,
                                  initialSelection: a
                                      .firstWhere(
                                        (element) =>
                                            element.label == state.karyawanName,
                                        orElse: () => const DropdownMenuEntry(
                                            value: -1, label: 'error'),
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
                        return const Text('error');
                      }
                    },
                  )),
                  BlocBuilder<InputserviceBloc, InputserviceState>(
                    builder: (context, state) {
                      if (state is InputserviceLoaded) {
                        // print(state.karyawanName);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${state.karyawanName} '),
                            GestureDetector(
                                onLongPress: () async {
                                  var a = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now());
                                  if (a != null) {
                                    BlocProvider.of<InputserviceBloc>(context)
                                        .add(ChangeTanggal(a));
                                  }
                                },
                                child: Text(
                                    DateFormat('dd/M/yyyy hh:mm', 'id_ID')
                                        .format(state.tanggal)
                                        .toString()))
                          ],
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(6)),
              BlocBuilder<InputserviceBloc, InputserviceState>(
                builder: (context, state) {
                  if (state is InputserviceLoaded) {
                    return Column(
                      children: [
                        for (var a in state.itemCards)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ItemCard(data: a),
                          ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              // ItemCard(),
              const Padding(padding: EdgeInsets.all(8)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<InputserviceBloc>(context)
                              .add(AddCard());
                        },
                        child: const Text('+')),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingButton extends StatelessWidget {
  FloatingButton({super.key});

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
                  num totalpembayaran = 0;
                  for (var e in state.itemCards) {
                    totalpembayaran += e.pcsBarang * e.price;
                  }
                  uangCustomer.text = totalpembayaran.toString();
                  showDialog(
                      context: context,
                      builder: (context) => Padding(
                          padding: const EdgeInsets.all(4),
                          child: AlertDialog(
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
                                                  child: Row(
                                                    children: [
                                                      Text(cardType[awo.type]),
                                                      if (awo.type == 3)
                                                        Text(
                                                            ' (${awo.namaBarang} ${awo.pcsBarang}x)'),
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
                                      textScaler: TextScaler.linear(1.25),
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
                          )));
                }
              });
        }
        return const SizedBox();
      },
    );
  }
}
