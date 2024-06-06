import 'package:another_flushbar/flushbar.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/bon_repo.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/model.dart';

class HutangHome extends StatefulWidget {
  const HutangHome({super.key, required this.namaKaryawan});
  final String namaKaryawan;

  @override
  State<HutangHome> createState() => _HutangHomeState();
}

class _HutangHomeState extends State<HutangHome> {
  // final textControl = TextEditingController();
  final uangFormatter = CurrencyTextInputFormatter.currency(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  final TextEditingController jumlahBon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Hutang')),
      body: Column(
        children: [
          FutureBuilder(
            future: RepositoryProvider.of<BonRepository>(context).getByNama(
              nama: widget.namaKaryawan,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                var total = 0.0;
                for (var e in snapshot.data!) {
                  total += e.jumlahBon * (e.tipe == BonType.berhutang ? -1 : 1);
                }
                return ListTile(
                    subtitle: Text(total.numberFormat(currency: true)),
                    title: const Text('Jumlah Hutang'));
              }
              return const CircularProgressIndicator();
            },
          ),
          Text(DateTime.now().formatLengkap()),
          const Padding(padding: EdgeInsets.all(8)),
          Expanded(
              child: FutureBuilder(
            future: RepositoryProvider.of<BonRepository>(context)
                .getByNama(nama: widget.namaKaryawan, tgl: DateTime.now()),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => ListTile(
                        subtitle:
                            Text(snapshot.data![index].tanggal!.clockOnly()),
                        title: Text(snapshot.data![index].jumlahBon
                                .toString()
                                .numberFormat(currency: true) ??
                            'parse err')));
              }
              return const CircularProgressIndicator();
            },
          )),
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                ///Dropdown : tipe=>[@default karyawan, lainnya]
                Row(
                  children: [
                    const Text('Subjek Bon : '),
                    Text('Karyawan: ${widget.namaKaryawan}'),
                  ],
                ),

                ///if karyawan=> show karyawan dropdown pick

                // Row(
                //   children: [
                //     Expanded(
                //         child: TextField(
                //       onChanged: (value) {
                //         setState(() {
                //           namaKaryawan = value;
                //         });
                //       },
                //       decoration: const InputDecoration(
                //           label: Text('Nama Subjek')),
                //     ))
                //   ],
                // ),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: jumlahBon,
                      inputFormatters: [uangFormatter],
                      decoration:
                          const InputDecoration(label: Text('Jumlah Uang')),
                    )),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green)),
                        onPressed: () async {
                          ///make safety var
                          if (jumlahBon.text.isNotEmpty) {
                            try {
                              await RepositoryProvider.of<BonRepository>(
                                      context)
                                  .addBon(BonData(
                                      author: Author.self,
                                      tanggal: DateTime.now(),
                                      namaSubjek: widget.namaKaryawan,
                                      jumlahBon: int.parse(uangFormatter
                                          .getUnformattedValue()
                                          .toString()),
                                      tipe: BonType.berhutang))
                                  .then((value) {
                                Flushbar(
                                  message: 'Success',
                                  duration: const Duration(seconds: 2),
                                  animationDuration: Durations.long1,
                                ).show(context);
                              }).onError((error, stackTrace) {
                                Flushbar(
                                  message: 'Error $error',
                                  duration: const Duration(seconds: 2),
                                  animationDuration: Durations.long1,
                                ).show(context);
                              });

                              setState(() {
                                jumlahBon.text = '';
                              });
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('There is some invalid data')));
                          }
                        },
                        child: const Text(
                          'Submit Bon/piutang',
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
