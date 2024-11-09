import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/cubit/theme_cubit.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/db.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/etc/lockscreen_keylock.dart';
import 'package:groom/model/model.dart';

class BottombarHome extends StatelessWidget {
  const BottombarHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 30),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            // borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
        Positioned(
            top: 0,
            right: 8,
            child: FloatingButton(
              formstate: GlobalKey(),
            )),
      ],
    );
  }
}

class FloatingButton extends StatelessWidget {
  FloatingButton({super.key, required this.formstate});
  final GlobalKey<FormState> formstate;
  final TextEditingController uangCustomer = TextEditingController();
  ontap(BuildContext builcontx) {
    showCupertinoDialog(
        barrierDismissible: true,
        context: builcontx,
        builder: (_) => BlocProvider.value(
              value: builcontx.read<InputserviceBloc>(),
              child: BlocBuilder<InputserviceBloc, InputserviceState>(
                builder: (context, state) {
                  if (state is InputserviceLoaded) {
                    num totalpembayaran = 0;
                    for (var e in state.itemCards) {
                      totalpembayaran += e.pcsBarang * e.price;
                    }
                    uangCustomer.text = totalpembayaran.toString();
                    return SafeArea(
                      child: AlertDialog(
                        actions: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      Colors.green[500])),
                              onPressed: () {
                                var karname =
                                    (BlocProvider.of<InputserviceBloc>(context)
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
                              style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Colors.red)),
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
                                      border: TableBorder.all(
                                          color: BlocProvider.of<ThemeCubit>(
                                                          context)
                                                      .state
                                                      .mode ==
                                                  ThemeMode.dark
                                              ? Colors.white
                                              : Colors.black),
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
                                                    Text(' (${awo.namaBarang})')
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              child: Text(
                                                (awo.price * awo.pcsBarang)
                                                        .toString()
                                                        .numberFormat(
                                                            currency: true) ??
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total :',
                                  textScaler: TextScaler.linear(1.25),
                                ),
                                Text(
                                  totalpembayaran.numberFormat(currency: true),
                                  textScaler: const TextScaler.linear(1.25),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    DropdownButton(
                                      value: state.tipePembayaran,
                                      items: const [
                                        DropdownMenuItem(
                                            value: TipePembayaran.cash,
                                            child: Text('Cash')),
                                        DropdownMenuItem(
                                            value: TipePembayaran.qris,
                                            child: Text('Qris'))
                                      ],
                                      onChanged: (value) {
                                        BlocProvider.of<InputserviceBloc>(
                                                context)
                                            .add(ChangeTipePembayaran(
                                                type: value ??
                                                    TipePembayaran.cash));
                                      },
                                    ),
                                  ],
                                ),
                                if (state.tipePembayaran.index == 1)
                                  StatefulBuilder(builder: (context, setstate) {
                                    var uangcust =
                                        (int.tryParse(uangCustomer.text) ?? 0);
                                    var kurangan = totalpembayaran - uangcust;
                                    var theteks = '0';
                                    if (uangcust == 0) {
                                      theteks = '0';
                                    } else if (kurangan > 0) {
                                      theteks = 'uang kurang';
                                    } else if (kurangan < 0) {
                                      theteks = (kurangan * -1).toString();
                                    }
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: uangCustomer,
                                                onTap: () =>
                                                    uangCustomer.selection =
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
                                                        label: Text('Uang')),
                                              ),
                                            )
                                          ],
                                        ),
                                        Text('Kembalian : Rp$theteks')
                                      ],
                                    );
                                  }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload),
            Text(
              'Submit',
              textScaler: TextScaler.linear(0.75),
            )
          ],
        ),
        onPressed: () {
          var clickstate = BlocProvider.of<InputserviceBloc>(context).state
              as InputserviceLoaded;
          if (clickstate.itemCards.isNotEmpty) {
            if ((formstate.currentState?.validate() ?? false) == false) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Ada kesalahan pengisian data.')));
              return;
            } else {
              ontap(context);
            }
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Empty')));
          }
        });
  }
}
