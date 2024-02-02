import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/model/bondata_mdl.dart';

class BonPage extends StatelessWidget {
  BonPage({super.key});
  final PageController thePageC = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bon/Piutang'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (value) {
          thePageC.animateToPage(value,
              duration: Durations.long1, curve: Curves.easeInOut);
        },
        items: [
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
            print(snapshot.data);
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Text('Empty'),
                );
              } else {
                return Text(snapshot.data!.toString());
              }
            } else {
              return Center(
                child: Text('Empty : null'),
              );
            }
            // return const CircularProgressIndicator();
          },
        ),

        ///show addbonpage
        const BonAddPage(),

        ///show bayarbonpage
        const BonDecreasePage(),
      ]),
    );
  }
}

class BonAddPage extends StatefulWidget {
  const BonAddPage({super.key});

  @override
  State<BonAddPage> createState() => _BonAddPageState();
}

class _BonAddPageState extends State<BonAddPage> {
  int typeValue = 0;
  String? namaKaryawan;
  TextEditingController jumlahBon = TextEditingController();

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
                        Text('Subjek Bon : '),
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
                        Expanded(child: SizedBox()),
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
                                          child: Text(
                                              '${snap.data![i].namaKaryawan}')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      namaKaryawan = value;
                                    });
                                  },
                                );
                              } else {
                                return Text('no karyawan data');
                              }
                            },
                          ),
                      ],
                    ),

                    ///if karyawan=> show karyawan dropdown pick

                    if (typeValue == 1)
                      const Row(
                        children: [
                          Expanded(
                              child: TextField(
                            decoration:
                                InputDecoration(label: Text('Nama Subjek')),
                          ))
                        ],
                      ),
                    Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: jumlahBon,
                          decoration:
                              InputDecoration(label: Text('Jumlah Uang')),
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
              try {
                await RepositoryProvider.of<BonRepository>(context).addBon(
                    BonData(
                        namaSubjek: namaKaryawan ?? '',
                        jumlahBon: int.parse(jumlahBon.text),
                        tipe: BonType.berhutang));
              } catch (e) {
                print(e);
              }
            },
            child: Text(
              'Submit Bon/piutang',
              style: TextStyle(color: Colors.white),
            )),
        ElevatedButton(
            onPressed: () async {
              var t = await RepositoryProvider.of<BonRepository>(context)
                  .getAllBon();
              print(t);
            },
            child: Text('try it!'))
      ],
    );
  }
}

class BonDecreasePage extends StatelessWidget {
  const BonDecreasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        /// if dropdown select karyawan: show current bon
        ///Dropdown : tipe=>[@default karyawan, lainnya]
        ///if karyawan=> show karyawan dropdown pick
        ///if lainnya=> show Textbox:subjek ,autocomplete
        ///Textbox: jumlah
      ],
    );
  }
}
