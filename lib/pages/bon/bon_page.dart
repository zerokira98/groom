import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/model/bondata_mdl.dart';
import 'package:intl/intl.dart';
import 'package:sembast/sembast.dart';

class BonPage extends StatefulWidget {
  const BonPage({super.key});

  @override
  State<BonPage> createState() => _BonPageState();
}

class _BonPageState extends State<BonPage> {
  final PageController thePageC = PageController();
  int indexPage = 0;
  @override
  void initState() {
    thePageC.addListener(() {
      if (thePageC.page!.toInt() != indexPage) {
        setState(() {
          indexPage = thePageC.page!.toInt();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: indexPage != 2
            ? const Text('Bon/Piutang')
            : const Text('Bayar utang'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indexPage,
        onTap: (value) {
          thePageC.animateToPage(value,
              duration: Durations.long1, curve: Curves.easeInOut);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'All'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Tambah'),
          BottomNavigationBarItem(icon: Icon(Icons.remove), label: 'Kurang'),
        ],
      ),
      body: PageView(controller: thePageC, children: [
        ///show all active(?) bon
        FutureBuilder(
          future: RepositoryProvider.of<BonRepository>(context).getAllBon(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Empty'),
                );
              } else {
                List<BonData> groupByPerson = [];
                for (var ele in snapshot.data!) {
                  var exist = groupByPerson
                      .any((element) => element.namaSubjek == ele.namaSubjek);
                  if (exist) {
                    groupByPerson = groupByPerson
                        .map((e) => e.namaSubjek == ele.namaSubjek
                            ? e.copyWith(
                                jumlahBon: e.jumlahBon +
                                    (ele.jumlahBon *
                                        (ele.tipe == BonType.berhutang
                                            ? -1
                                            : 1)),
                              )
                            : e)
                        .toList();
                  } else {
                    groupByPerson.add(ele.copyWith(
                        jumlahBon: ele.jumlahBon *
                            (ele.tipe == BonType.berhutang ? -1 : 1)));
                  }
                  for (var e in groupByPerson) {
                    groupByPerson = groupByPerson
                        .map((e) => e.copyWith(
                            tipe: e.jumlahBon < 0
                                ? BonType.berhutang
                                : BonType.bayarhutang))
                        .toList();
                  }
                }
                return SingleChildScrollView(
                  child: Column(
                    children: List.generate(groupByPerson.length, (index) {
                      if (index == 1) {
                        return IconButton(
                            onPressed: () {
                              setState(() {});
                            },
                            icon: const Icon(Icons.refresh));
                      }
                      BonData i = groupByPerson[index];
                      return Card(
                        elevation: 2,
                        child: Container(
                          child: ListTile(
                            onTap: () {
                              var ttt = snapshot.data!
                                  .where((element) =>
                                      element.namaSubjek == i.namaSubjek)
                                  .toList();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: ListView.builder(
                                      itemCount: ttt.length,
                                      itemBuilder: (context, index) => ListTile(
                                        title: Text(ttt[index].tipe.name),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(ttt[index]
                                                .jumlahBon
                                                .toString()),
                                            Text(ttt[index]
                                                    .tanggal
                                                    ?.toString() ??
                                                'tanggal'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            title: Text(i.namaSubjek),
                            subtitle: Text(i.jumlahBon.toString()),
                            // Text(i.tipe.toString()),
                          ),
                        ),
                      );
                    }),
                    // for (var i in snapshot.data!)
                  ),
                );
              }
            } else {
              return const Center(
                child: Text('Empty : null'),
              );
            }
            // return const CircularProgressIndicator();
          },
        ),

        ///show addbonpage
        BonAddPage(pc: thePageC),

        ///show bayarbonpage
        BonDecreasePage(pc: thePageC),
      ]),
    );
  }
}

class BonAddPage extends StatefulWidget {
  final PageController pc;
  const BonAddPage({super.key, required this.pc});

  @override
  State<BonAddPage> createState() => _BonAddPageState();
}

class _BonAddPageState extends State<BonAddPage> {
  int typeValue = 0;
  String? namaKaryawan;
  // TextEditingController jumlahBon = TextEditingController();

  var uangFormatter = CurrencyTextInputFormatter(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  valid() {
    return (uangFormatter.getUnformattedValue() != 0) &&
        (namaKaryawan != null || namaKaryawan!.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// if dropdown select karyawan: show current bon
        ///if lainnya=> show Textbox:subjek ,autocomplete
        ///Textbox: jumlah
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    ///Dropdown : tipe=>[@default karyawan, lainnya]
                    Row(
                      children: [
                        const Text('Subjek Bon : '),
                        DropdownButton(
                          value: typeValue,
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('Karyawan')),
                            DropdownMenuItem(value: 1, child: Text('Lainnya')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                typeValue = value;
                              });
                            }
                            print(value);
                          },
                        ),
                        const Expanded(child: SizedBox()),
                        if (typeValue == 0)
                          FutureBuilder(
                            future: RepositoryProvider.of<KaryawanRepository>(
                                    context)
                                .getAllKaryawan(),
                            builder: (_, snap) {
                              if (snap.hasData) {
                                return DropdownButton(
                                  value: namaKaryawan,
                                  items: [
                                    for (var i = 0; i < snap.data!.length; i++)
                                      DropdownMenuItem(
                                          value: snap.data![i].namaKaryawan,
                                          child:
                                              Text(snap.data![i].namaKaryawan)),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      namaKaryawan = value;
                                    });
                                  },
                                );
                              } else {
                                return const Text('no karyawan data');
                              }
                            },
                          ),
                      ],
                    ),

                    ///if karyawan=> show karyawan dropdown pick

                    if (typeValue == 1)
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            onChanged: (value) {
                              setState(() {
                                namaKaryawan = value;
                              });
                            },
                            decoration: const InputDecoration(
                                label: Text('Nama Subjek')),
                          ))
                        ],
                      ),
                    Row(
                      children: [
                        Expanded(
                            child: TextField(
                          // controller: jumlahBon,
                          inputFormatters: [uangFormatter],
                          decoration:
                              const InputDecoration(label: Text('Jumlah Uang')),
                        ))
                      ],
                    )
                  ]),
                ),
              ),
            ),
          ],
        ),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green)),
            onPressed: () async {
              ///make safety var
              if (valid()) {
                try {
                  await RepositoryProvider.of<BonRepository>(context)
                      .addBon(BonData(
                          tanggal: DateTime.now(),
                          namaSubjek: namaKaryawan ?? '',
                          jumlahBon: int.parse(
                              uangFormatter.getUnformattedValue().toString()),
                          tipe: BonType.berhutang))
                      .then((value) {
                    widget.pc.animateToPage(0,
                        duration: Durations.long1, curve: Curves.easeInOut);
                  });
                } catch (e) {
                  print(e);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('There is some invalid data')));
              }
            },
            child: const Text(
              'Submit Bon/piutang',
              style: TextStyle(color: Colors.white),
            )),
        // ElevatedButton(
        //     onPressed: () async {
        //       // var t = await RepositoryProvider.of<BonRepository>(context)
        //       //     .getAllBon();
        //       print(uangFormatter.getUnformattedValue().toString());
        //     },
        //     child: const Text('try it!'))
      ],
    );
  }
}

class BonDecreasePage extends StatefulWidget {
  final PageController pc;
  const BonDecreasePage({super.key, required this.pc});

  @override
  State<BonDecreasePage> createState() => _BonDecreasePageState();
}

class _BonDecreasePageState extends State<BonDecreasePage> {
  int typeValue = 0;
  String? namaKaryawan;
  // TextEditingController jumlahBon = TextEditingController();

  var uangFormatter = CurrencyTextInputFormatter(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  valid() {
    return (uangFormatter.getUnformattedValue() != 0) &&
        (namaKaryawan != null || namaKaryawan!.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    ///Dropdown : tipe=>[@default karyawan, lainnya]
                    Row(
                      children: [
                        const Text('Subjek Bon : '),
                        DropdownButton(
                          value: typeValue,
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('Karyawan')),
                            DropdownMenuItem(value: 1, child: Text('Lainnya')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                typeValue = value;
                              });
                            }
                            print(value);
                          },
                        ),
                        const Expanded(child: SizedBox()),
                        if (typeValue == 0)
                          FutureBuilder(
                            future: RepositoryProvider.of<KaryawanRepository>(
                                    context)
                                .getAllKaryawan(),
                            builder: (_, snap) {
                              if (snap.hasData) {
                                return DropdownButton(
                                  value: namaKaryawan,
                                  items: [
                                    for (var i = 0; i < snap.data!.length; i++)
                                      DropdownMenuItem(
                                          value: snap.data![i].namaKaryawan,
                                          child:
                                              Text(snap.data![i].namaKaryawan)),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      namaKaryawan = value;
                                    });
                                  },
                                );
                              } else {
                                return const Text('no karyawan data');
                              }
                            },
                          ),
                      ],
                    ),

                    ///if karyawan=> show karyawan dropdown pick

                    if (typeValue == 1)
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            controller:
                                TextEditingController(text: namaKaryawan),
                            onChanged: (value) {
                              namaKaryawan = value;
                            },
                            decoration: const InputDecoration(
                                label: Text('Nama Subjek')),
                          ))
                        ],
                      ),
                    Row(
                      children: [
                        Expanded(
                            child: TextField(
                          // controller: jumlahBon,
                          inputFormatters: [uangFormatter],
                          decoration:
                              const InputDecoration(label: Text('Jumlah Uang')),
                        ))
                      ],
                    )
                  ]),
                ),
              ),
            ),
          ],
        ),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green)),
            onPressed: () async {
              ///make safety var
              var get = await RepositoryProvider.of<BonRepository>(context)
                  .getBonFiltered(Filter.equals('namaSubjek', namaKaryawan));
              //negative == punya hutang
              num totalBon = 0;
              if (get.isNotEmpty) {
                for (var e in get) {
                  totalBon +=
                      e.jumlahBon * (e.tipe == BonType.berhutang ? -1 : 1);
                }
                if (valid() &&
                    totalBon +
                            int.parse(uangFormatter
                                .getUnformattedValue()
                                .toString()) <=
                        0) {
                  try {
                    await RepositoryProvider.of<BonRepository>(context)
                        .addBon(BonData(
                            namaSubjek: namaKaryawan ?? '',
                            tanggal: DateTime.now(),
                            jumlahBon: int.parse(
                                uangFormatter.getUnformattedValue().toString()),
                            tipe: BonType.bayarhutang))
                        .then((value) {
                      widget.pc.animateToPage(0,
                          duration: Durations.long1, curve: Curves.easeInOut);
                    });
                  } catch (e) {
                    print(e);
                  }
                } else {
                  var message = totalBon == 0
                      ? 'subjek[$namaKaryawan] tidak memiliki hutang'
                      : totalBon +
                                  int.parse(uangFormatter
                                      .getUnformattedValue()
                                      .toString()) >
                              0
                          ? 'melebihi jumlah utang ${NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp',
                              decimalDigits: 0,
                            ).format(totalBon)}'
                          : '$totalBon';
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('There is some invalid data\n$message')));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('$namaKaryawan tidak memiliki hutang')));
              }
            },
            child: const Text(
              'Bayar hutang',
              style: TextStyle(color: Colors.white),
            )),
        // ElevatedButton(
        //     onPressed: () async {
        //       // var t = await RepositoryProvider.of<BonRepository>(context)
        //       //     .getAllBon();
        //       print(uangFormatter.getUnformattedValue().toString());
        //     },
        //     child: const Text('try it!'))
      ],
    );
  }
}
