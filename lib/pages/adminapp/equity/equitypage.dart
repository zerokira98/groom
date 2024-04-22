import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/bon_repo.dart';
import 'package:groom/db/pemasukan_repo.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/db/uangmasuk_repo.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/model.dart';
import 'package:intl/intl.dart';

class EkuitasPage extends StatefulWidget {
  const EkuitasPage({super.key});

  @override
  State<EkuitasPage> createState() => _EkuitasPageState();
}

class _EkuitasPageState extends State<EkuitasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemasukan Uang'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  Future.delayed(const Duration(milliseconds: 450), () {
                setState(() {});
              }),
              child: FutureBuilder(
                  future: RepositoryProvider.of<EkuitasRepository>(context)
                      .getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data == null) {
                        return const SizedBox();
                      } else {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              for (var a in snapshot.data!)
                                ListTile(
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      RepositoryProvider.of<EkuitasRepository>(
                                              context)
                                          .delete(a)
                                          .then((value) => value == 1
                                              ? setState(() {})
                                              : null);
                                    },
                                  ),
                                  title: Text(a.deskripsi),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(a.uang
                                              .toInt()
                                              .toString()
                                              .numberFormat(currency: true) ??
                                          'parse err'),
                                      Text(a.tanggal.formatLengkap())
                                    ],
                                  ),
                                )
                            ],
                          ),
                        );
                      }
                    } else {
                      return const SizedBox();
                    }
                  }),
            ),
          ),
          const ReportCard(),
          InputCard(setstate: setState)
        ],
      ),
    );
  }
}

class InputCard extends StatefulWidget {
  final void Function(VoidCallback fn) setstate;
  const InputCard({super.key, required this.setstate});

  @override
  State<InputCard> createState() => _InputCardState();
}

class _InputCardState extends State<InputCard> {
  final TextEditingController deskripsi = TextEditingController();

  final TextEditingController uang = TextEditingController();

  final TextEditingController tanggal = TextEditingController(
      text: DateFormat.yMd('id_ID').format(DateTime.now()));

  final uangFormatter = CurrencyTextInputFormatter(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    validator: (value) {
                      if (value == null) return null;
                      if (value.isEmpty) return 'cant empty';
                      return null;
                    },
                    controller: deskripsi,
                    onChanged: (value) {
                      // BlocProvider.of<InputserviceBloc>(context).add(
                      //     ChangeItemDetails(
                      //         idx: data.index,
                      //         data: data.copyWith(namaBarang: value)));
                    },
                    decoration: const InputDecoration(label: Text('Deskripsi')),
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: uang,
                    validator: (value) {
                      if (value == null) {
                        return null;
                      } else if (uangFormatter
                              .getUnformattedValue()
                              .toString()
                              .length <=
                          2) {
                        return 'too small';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [uangFormatter],
                    onChanged: (value) {
                      if (int.tryParse(value) != null) {
                        // BlocProvider.of<InputserviceBloc>(context).add(
                        //     ChangeItemDetails(
                        //         idx: data.index,
                        //         data: data.copyWith(price: int.tryParse(value))));
                      }
                    },
                    decoration: const InputDecoration(label: Text('Uang')),
                  )),
                  const Padding(padding: EdgeInsets.all(4)),
                  Expanded(
                      child: TextFormField(
                          controller: tanggal,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null) return null;
                            try {
                              DateFormat.yMd('id_ID').parseStrict(value);
                              return null;
                            } on FormatException catch (e) {
                              return e.message.toString();
                            }
                          },
                          onChanged: (value) {
                            widget.setstate(() {});
                            debugPrint(DateFormat.yMd('id_ID')
                                .tryParseStrict(value)
                                .toString());
                          },
                          decoration: InputDecoration(
                              label: const Text('Tanggal'),
                              errorMaxLines: 2,
                              suffixIcon: InkWell(
                                onTap: () {
                                  showDatePicker(
                                          context: context,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now())
                                      .then((value) {
                                    if (value != null) {
                                      widget.setstate(() {
                                        tanggal.text = DateFormat.yMd('id_ID')
                                            .format(value);
                                      });
                                    }
                                  });
                                },
                                child: const Icon(Icons.calendar_today),
                              ))))
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          RepositoryProvider.of<EkuitasRepository>(context).add(
                              EkuitasMdl(
                                  tanggal: DateFormat.yMd('id_ID')
                                      .parseStrict(tanggal.text),
                                  uang: uangFormatter.getUnformattedValue(),
                                  deskripsi: deskripsi.text));
                          widget.setstate(() {
                            deskripsi.clear();
                            uang.clear();
                          });
                          // .then((value) =>
                          //     value == 1 ? Navigator.pop(context) : null);
                        }
                      },
                      child: const Text('Submit'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ReportCard extends StatefulWidget {
  const ReportCard({super.key});

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  num totalekuitas = 0;
  num totalpemasukan = 0;

  num totalPengeluaran = 0;
  num totalbon = 0;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Masuk :'),

                ///total ekuitas
                FutureBuilder(
                  future: RepositoryProvider.of<EkuitasRepository>(context)
                      .getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      totalekuitas = 0;
                      for (var e in snapshot.data!) {
                        totalekuitas += e.uang;
                      }
                      return Text(
                          'Total Uang Masuk: ${totalekuitas.toInt().toString().numberFormat(currency: true)}');
                    } else {
                      return const SizedBox();
                    }
                  },
                ),

                ///Struk income
                FutureBuilder(
                  future: RepositoryProvider.of<PemasukanRepository>(context)
                      .getAllStruk(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      totalpemasukan = 0;
                      num totalqris = 0;
                      for (var e in snapshot.data!) {
                        for (var a in e.itemCards) {
                          totalpemasukan += a.pcsBarang * a.price;
                          totalqris += e.tipePembayaran == TipePembayaran.qris
                              ? a.pcsBarang * a.price
                              : 0;
                        }
                      }
                      return Text(
                          'Total All Income : ${totalpemasukan.toInt().toString().numberFormat(currency: true)}');
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                // Row(
                //   children: [
                //     Expanded(
                //         child: Container(
                //             padding: const EdgeInsets.all(8),
                //             decoration: BoxDecoration(
                //                 gradient: LinearGradient(colors: [
                //               Theme.of(context).primaryColorDark,
                //               Theme.of(context).primaryColorDark,
                //               Theme.of(context)
                //                   .primaryColorDark
                //                   .withOpacity(0.45)
                //             ])),
                //             child: const
                const Text('Keluar :'),
                // ))
                //   ],
                // ),

                ///Pengeluaran
                FutureBuilder(
                  future: RepositoryProvider.of<PengeluaranRepository>(context)
                      .getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      totalPengeluaran = 0;
                      for (var e in snapshot.data!) {
                        totalPengeluaran += e.pcs * e.biaya;
                      }
                      return Text(
                          'Pengeluaran All tanpaBon : ${totalPengeluaran.toInt().toString().numberFormat(currency: true)}');
                    } else {
                      return const SizedBox();
                    }
                  },
                ),

                ///Bon
                FutureBuilder(
                  future:
                      RepositoryProvider.of<BonRepository>(context).getAllBon(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      totalbon = 0;
                      for (var e in snapshot.data!) {
                        totalbon += e.jumlahBon *
                            (e.tipe == BonType.berhutang ? -1 : 1);
                      }

                      return Text(
                          'Pengeluaran Bon : ${totalbon.toInt().toString().numberFormat(currency: true)}');
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                const Padding(padding: EdgeInsets.all(4)),
                Text(
                    'Total kas sekarang : ${(totalekuitas + totalpemasukan - totalPengeluaran + totalbon).toInt().toString().numberFormat(currency: true)}')
              ],
            ),
            IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh_sharp)),
          ],
        ),
      ),
    );
  }
}
