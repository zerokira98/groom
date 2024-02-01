import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/itemcard_mdl.dart';

class RiwayatPemasukan extends StatefulWidget {
  const RiwayatPemasukan({super.key});

  @override
  State<RiwayatPemasukan> createState() => _RiwayatPemasukanState();
}

class _RiwayatPemasukanState extends State<RiwayatPemasukan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pemasukan')),
      body: FutureBuilder(
        future: RepositoryProvider.of<PemasukanRepository>(context)
            .getStrukFiltered({
          'tanggalStart': DateTime.now().subtract(const Duration(days: 1)),
          'tanggalEnd': DateTime.now().subtract(const Duration(days: 0))
        }),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var theData = snapshot.data![index];
                int total = 0;
                StringBuffer servicelist =
                    StringBuffer('${theData.namaKaryawan} : ');
                for (var e in theData.itemCards) {
                  servicelist.write(cardType[e.type] + ', ');
                  total += e.price * (e.pcsBarang ?? 1);
                }
                return Column(
                  children: [
                    if (index >= 1 &&
                            snapshot.data![index].tanggal.day !=
                                snapshot.data![index - 1].tanggal.day ||
                        index == 0)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin:
                                    const EdgeInsets.only(bottom: 8.0, top: 8),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                  Theme.of(context).primaryColorDark,
                                  Theme.of(context).primaryColorDark,
                                  Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.45)
                                ])),
                                // color: ,
                                child: Text(
                                  theData.tanggal.formatLengkap(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ]),
                    ListTile(
                      trailing: InkWell(
                          onTap: () async {
                            var dia = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Yakin untuk menghapus?'),
                                  actions: [
                                    ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.green)),
                                        onPressed: () async {
                                          try {
                                            var a = await RepositoryProvider.of<
                                                        PemasukanRepository>(
                                                    context)
                                                .deleteStruk(theData);
                                            debugPrint(a.toString());
                                            Navigator.pop(context, true);
                                          } catch (e) {
                                            debugPrint(e.toString());
                                          }
                                        },
                                        child: const Text('Hapus')),
                                    ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red)),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Batal')),
                                  ],
                                  content: Row(
                                    children: [
                                      const Text('Alasan : '),
                                      Expanded(
                                          child: DropdownMenu(
                                        dropdownMenuEntries: const [
                                          DropdownMenuEntry(
                                              value: 0,
                                              label: 'Salah input data'),
                                        ],
                                        initialSelection: 0,
                                        onSelected: (value) {},
                                      ))
                                    ],
                                  ),
                                );
                              },
                            );
                            if (dia != null && dia == true) {
                              setState(() {});
                            }
                          },
                          child: const Icon(Icons.delete)),
                      title: Text(servicelist.toString()),
                      subtitle: Text('Total: $total'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            print(theData.itemCards);
                            return Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Text(theData.namaKaryawan),
                                    for (var e in theData.itemCards)
                                      Row(
                                        children: [
                                          Text('${cardType[e.type]} : '),
                                          Text(e.price.toString())
                                        ],
                                      )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
