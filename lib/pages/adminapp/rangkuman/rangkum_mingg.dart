import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/bon_repo.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/model.dart';
import 'package:groom/pages/pengeluaran/pengeluaran_histori.dart';
import 'package:groom/pages/print/print_to_excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fc;
import 'package:weekly_date_picker/datetime_apis.dart';
import 'cubitmingguan/rangkumanmingg_cubit.dart';

class RangkumanMingguan extends StatelessWidget {
  const RangkumanMingguan({super.key});

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rangkuman Mingguan'),
      ),
      body: BlocBuilder<RangkumanWeekCubit, RangkumanWeekState>(
        builder: (context, state) {
          if (state is RangkumanWeekLoaded) {
            List<double> perpersonTotal = [];
            // if (state.groupBy.index == 0) {
            for (var i = 0; i < state.dataPerPerson.length; i++) {
              var countPrice = 0.0;
              for (var e in state.dataPerPerson[i].itemCards) {
                countPrice += e.price;
              }
              perpersonTotal.add(countPrice);
            }

            return Column(children: [
              Row(
                children: [
                  const Text('Order by person?'),
                  Checkbox(
                    value: state.groupBy == GroupBy.namaKayrawan,
                    onChanged: (value) {
                      var sd = state.tanggalStart;
                      var ed = state.tanggalEnd;
                      if (value!) {
                        BlocProvider.of<RangkumanWeekCubit>(context).loadData({
                          'tanggalStart': sd,
                          'tanggalEnd': ed,
                          'groupBy': GroupBy.namaKayrawan
                        });
                      } else {
                        BlocProvider.of<RangkumanWeekCubit>(context).loadData({
                          'tanggalStart': sd,
                          'tanggalEnd': ed,
                        });
                      }
                    },
                  ),
                  IconButton(
                      onPressed: () {
                        // debugPrint(state.daily.first.keys);
                        showDialog(
                          context: context,
                          builder: (context) => PrintMingguan(
                            perDay: state.daily,
                            startDate: state.tanggalStart,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print))
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    firstDate: DateTime(now.year - 5),
                    lastDate: now.add(const Duration(days: 7)),
                  ).then((value) {
                    if (value != null) {
                      var ts = DateTime(value.year, value.month, value.day)
                          .subtract(Duration(days: value.weekday));
                      var te = ts.add(const Duration(days: 7));
                      BlocProvider.of<RangkumanWeekCubit>(context).loadData({
                        'tanggalStart': ts,
                        'tanggalEnd': te,
                      });
                    }
                  });
                },
                child: Text(
                    'Week ${state.tanggalStart.formatLengkap()}-${state.tanggalEnd.subtract(Durations.extralong1).formatLengkap()}'),
              ),
              if (state.groupBy == GroupBy.date)
                Expanded(
                    child: ListView.builder(
                  itemCount: state.daily.length,
                  itemBuilder: (context, index) {
                    var totalHarian = 0;
                    for (var ew in state.daily[index + 0]) {
                      totalHarian += ew.totalPendapatan;
                    }
                    var separatorStyle = const TextStyle(color: Colors.white);
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Theme.of(context).primaryColorDark,
                            Theme.of(context).primaryColorDark,
                            Theme.of(context).primaryColorDark.withOpacity(0.45)
                          ])),
                          child: Row(
                            children: [
                              Text(
                                ///add state tanggal
                                // state.daily[index + 0].formatLengkap(),
                                'tanggal',
                                style: separatorStyle,
                              ),
                              const Expanded(child: SizedBox()),
                              Text('Total Hari ini:', style: separatorStyle),
                              Text(totalHarian.numberFormat(currency: true),
                                  style: separatorStyle)
                            ],
                          ),
                        ),
                        for (var z in state.daily[index + 0])
                          ListTile(
                            onTap: () {
                              // debugPrint(state.daily[index + 0]);
                            },
                            title: Text(z.namaKaryawan),
                            subtitle: Text(
                                z.totalPendapatan.numberFormat(currency: true)),
                          ),
                      ],
                    );
                  },
                )),
              if (state.groupBy == GroupBy.namaKayrawan)
                Expanded(
                    child: ListView.builder(
                  itemCount: state.dataPerPerson.length,
                  itemBuilder: (context, index) {
                    return TileMingguan(
                        dataState: state,
                        total: perpersonTotal[index],
                        index: index);
                  },
                )),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Total income: ${state.totalKotor.toString().numberFormat(currency: true)}'),
                  Text(
                      'Income-bagihasil: ${(state.totalKotor - state.totalBagiHasil).toString().numberFormat()}'),
                  Text('Pengeluaran: ${state.pengeluaran}+bon:${state.bon}'),
                ],
              )
            ]);
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class TileMingguan extends StatelessWidget {
  final RangkumanWeekLoaded dataState;
  final double total;
  final int index;
  const TileMingguan(
      {super.key,
      required this.dataState,
      required this.total,
      required this.index});

  @override
  Widget build(BuildContext context) {
    StrukMdl data = dataState.dataPerPerson[index];
    return FutureBuilder(
        future: RepositoryProvider.of<BonRepository>(context).getBonFiltered(
            fc.Filter('namaSubjek', isEqualTo: data.namaKaryawan)),
        builder: (context, snapshot) {
          double cutPercentage(int type) => switch (type) {
                0 => 0.48,
                1 => 0.5,
                2 => 0.5,
                3 => 0.1,
                int() => 1,
              };
          double tot = 0;

          for (var awo in data.itemCards) {
            tot += awo.price * cutPercentage(awo.type);
          }
          num hutang = 0;
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            for (var e in snapshot.data!) {
              hutang += e.jumlahBon * (e.tipe == BonType.berhutang ? -1 : 1);
            }
          }
          return ListTile(
            title: Text(data.namaKaryawan),
            subtitle: Row(
              children: [
                Text(total.toString()),
                const Expanded(child: SizedBox()),
                const Text('Expected payment: '),
                Text((tot + hutang)
                        .toInt()
                        .toString()
                        .numberFormat(currency: true) ??
                    'err pars'),
              ],
            ),
            onTap: () {
              bool boolUtang = false;
              showDialog(
                useRootNavigator: false,
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (BuildContext context,
                        void Function(void Function()) setState) {
                      return AlertDialog(
                        actionsOverflowAlignment: OverflowBarAlignment.center,
                        actionsAlignment: MainAxisAlignment.center,
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(data.namaKaryawan),
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => SlipGaji(
                                            dataState: dataState,
                                            nama: data.namaKaryawan));
                                  },
                                  icon: const Icon(Icons.print))
                            ],
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  foregroundColor:
                                      const MaterialStatePropertyAll(
                                          Colors.white),
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.green[800])),
                              onPressed: () async {
                                var te = dataState.tanggalEnd;
                                var checkdata = await RepositoryProvider.of<
                                        PengeluaranRepository>(context)
                                    .getByOrder(
                                      TipePengeluaran.gaji,
                                      starts: DateUtils.dateOnly(te),
                                      ends: DateUtils.dateOnly(
                                          te.add(const Duration(days: 1))),
                                    )
                                    .then((value) => value
                                        .map((e) =>
                                            e.karyawan == data.namaKaryawan
                                                ? e
                                                : e)
                                        .nonNulls
                                        .toList());
                                if (boolUtang && (tot + hutang).toInt() < 0) {
                                  await Flushbar(
                                    message: 'Mines Pak!',
                                    duration: const Duration(seconds: 2),
                                    animationDuration: Durations.long1,
                                  ).show(context);
                                  return;
                                }
                                if (DateTime.now().isAfter(te) &&
                                    checkdata.isEmpty) {
                                  RepositoryProvider.of<PengeluaranRepository>(
                                          context)
                                      .insert(PengeluaranMdl(
                                          tanggalPost: DateTime.now(),
                                          tanggal: DateUtils.dateOnly(te),
                                          namaPengeluaran: data.namaKaryawan,
                                          tipePengeluaran: TipePengeluaran.gaji,
                                          pcs: 1,
                                          biaya:
                                              tot + (boolUtang ? hutang : 0)))
                                      .then((value) {
                                    if (boolUtang) {
                                      RepositoryProvider.of<BonRepository>(
                                              context)
                                          .addBon(BonData(
                                              tanggal: DateTime.now(),
                                              namaSubjek: data.namaKaryawan,
                                              jumlahBon: hutang.abs().toInt(),
                                              tipe: BonType.bayarhutang))
                                          .then((value) =>
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const HistoriPengeluaran(
                                                      sortBy:
                                                          TipePengeluaran.gaji,
                                                    ),
                                                  )));
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HistoriPengeluaran(
                                              sortBy: TipePengeluaran.gaji,
                                            ),
                                          ));
                                    }
                                  });
                                } else {
                                  var msgerr = 'Sekarang bukan waktunya gajian';
                                  if (checkdata.isNotEmpty) {
                                    msgerr = 'sudah tercatat(?)';
                                  }
                                  await Flushbar(
                                    message: msgerr,
                                    duration: const Duration(seconds: 3),
                                    animationDuration: Durations.long1,
                                  ).show(context);
                                }
                              },
                              child: const Text('Bayar & Catat Pengeluaran')),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Batal'))
                        ],
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Table(
                              border: TableBorder.all(),
                              children: [
                                for (var awo in data.itemCards)
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Text(cardType[awo.type]),
                                    ),
                                    Text(
                                      awo.price.toString(),
                                      textAlign: TextAlign.end,
                                    ),
                                    Text(' ${cutPercentage(awo.type)}'),
                                    Text(
                                      (awo.price * cutPercentage(awo.type))
                                          .toString(),
                                      textAlign: TextAlign.end,
                                    ),
                                  ])
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Text('Total : '),
                                    const Expanded(child: SizedBox()),
                                    Text(tot
                                        .toInt()
                                        .toString()
                                        .numberFormat(currency: true)
                                        .toString()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Hutang : ',
                                      style: TextStyle(
                                          decoration: !boolUtang
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    Text(
                                      hutang >= 0
                                          ? '0'
                                          : '$hutang'.numberFormat().toString(),
                                      style: TextStyle(
                                          decoration: !boolUtang
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      const Text('Expected payment: '),
                                      const Expanded(child: SizedBox()),
                                      Text(
                                          ' ${(tot + (boolUtang ? hutang : 0)).toInt().toString().numberFormat(currency: true)}'),
                                    ],
                                  ),
                                ),
                                if (hutang != 0)
                                  Row(
                                    children: [
                                      const Text(
                                        'Bayar hutang?',
                                      ),
                                      Checkbox(
                                        value: boolUtang,
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              boolUtang = value;
                                            });
                                          }
                                        },
                                      )
                                    ],
                                  ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        });
  }
}

class SlipGaji extends StatefulWidget {
  final RangkumanWeekLoaded dataState;
  final String nama;
  const SlipGaji({super.key, required this.dataState, required this.nama});

  @override
  State<SlipGaji> createState() => _SlipGajiState();
}

class _SlipGajiState extends State<SlipGaji> {
  Future<Widget> bon() async {
    ///total
    var a = await RepositoryProvider.of<BonRepository>(context)
        .getByNama(nama: widget.nama);

    ///get week
    var aWeek = await RepositoryProvider.of<BonRepository>(context)
        .getByNama(
            nama: widget.nama,
            tgl: DateUtils.dateOnly(widget.dataState.tanggalStart),
            tglEnd: DateUtils.dateOnly(widget.dataState.tanggalEnd))
        .then((value) => value
            // .map((e) => e.tipe == BonType.bayarhutang ? e : null)
            .nonNulls
            .toList());
    var b = BonData(
        namaSubjek: widget.nama,
        jumlahBon: 0,
        tipe: BonType.berhutang,
        tanggal: DateTime.now());
    // var jumlahbon = 0;
    for (var w in a) {
      var ey = w.jumlahBon * (w.tipe == BonType.berhutang ? -1 : 1);
      b = b.copyWith(
          jumlahBon: b.jumlahBon + ey,
          tipe: b.jumlahBon + ey > 0 ? BonType.bayarhutang : BonType.berhutang);
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Sisa Hutang : '),
              Expanded(
                child: ListTile(
                  title: Text(b.jumlahBon.numberFormat(currency: true)),
                ),
              )
            ],
          ),
          const Text('Histori catatan utang minggu ini'),
          for (var i in aWeek)
            ListTile(
              title: Text(
                  (i.jumlahBon * (i.tipe == BonType.bayarhutang ? -1 : 1))
                      .numberFormat()),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(i.tanggal!.formatLengkap()),
                  Text(i.tanggal!.clockOnly()),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget databon = Container();
  @override
  void initState() {
    bon().then((value) {
      setState(() {
        databon = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<PerPerson> waw = List.generate(
      7,
      (index) => PerPerson(
          namaKaryawan: widget.nama, perCategory: const [], totalPendapatan: 0),
    );
    List<ItemCardMdl> groundItemCards = List.generate(
        cardType.length, (i) => ItemCardMdl(index: 0, price: 0, type: i));
    num totHC = 0, totSHV = 0, totCLR = 0, totBRG = 0;
    for (var i = 0; i < 7; i++) {
      waw[i] = widget.dataState.daily[i].firstWhere(
        (element) => element.namaKaryawan == widget.nama,
        orElse: () => PerPerson(
            namaKaryawan: widget.nama,
            perCategory: groundItemCards,
            totalPendapatan: 0),
      );
      totHC +=
          waw[i].perCategory.firstWhere((element) => element.type == 0).price;
      totSHV +=
          waw[i].perCategory.firstWhere((element) => element.type == 1).price;
      totCLR +=
          waw[i].perCategory.firstWhere((element) => element.type == 2).price;
      totBRG +=
          waw[i].perCategory.firstWhere((element) => element.type == 3).price *
              waw[i]
                  .perCategory
                  .firstWhere((element) => element.type == 3)
                  .pcsBarang;
    }
    return Dialog.fullscreen(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Karyawan : ${widget.nama}',
                  textScaler: const TextScaler.linear(1.75)),
            ),
            Table(
              children: [
                const TableRow(children: [
                  Text('Tgl'),
                  Text('HC'),
                  Text('SHV'),
                  Text('SMR'),
                  Text('BRG'),
                ]),
                for (var i = 0; i < 7; i++,)
                  TableRow(children: [
                    Text(widget.dataState.tanggalStart
                        .addDays(i)
                        .formatDayMonth()),
                    Text((waw[i].perCategory[0].price * 0.48).numberFormat()),
                    Text((waw[i].perCategory[1].price * 0.5).numberFormat()),
                    Text((waw[i].perCategory[2].price * 0.5).numberFormat()),
                    Text((waw[i].perCategory[3].price * 0.1).numberFormat()),
                  ]),
                TableRow(children: [
                  const Text('Total : '),
                  Text((totHC * 0.48).numberFormat()),
                  Text((totSHV * 0.5).numberFormat()),
                  Text((totCLR * 0.5).numberFormat()),
                  Text((totBRG * 0.1).numberFormat()),
                ])
              ],
            ),
            Row(
              children: [
                const Text('Total : '),
                Text(((totHC * 0.48) +
                        (totSHV * 0.5) +
                        (totCLR * 0.5) +
                        (totBRG * 0.1))
                    .numberFormat())
              ],
            ),
            databon
          ],
        ),
      ),
    );
  }
}
