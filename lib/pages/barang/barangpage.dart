import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/barang_repo.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/model.dart';
import 'package:groom/pages/barang/tambahbarang.dart';

class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  void restate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang inventori'),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const TambahBarang(),
                      )).then((value) {
                    // if (value != null && value) {
                    // }
                    setState(() {});
                    // return null;
                  }),
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
        future: RepositoryProvider.of<BarangRepository>(context).getAll(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data!.isEmpty) return const Text('Empty');
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, i) {
                  return ListTile(
                      onTap: () {
                        showDialog<bool>(
                          context: context,
                          builder: (context) => BarangEditDialog(
                              data: snapshot.data![i], restate: restate),
                        ).then((value) {
                          if (value != null && value) {
                            setState(() {});
                            return;
                          }
                          setState(() {});
                        });
                      },
                      title: Text(snapshot.data![i].namaBarang),
                      subtitle: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'Beli : ${snapshot.data![i].hargabeli.numberFormat(currency: true)}'),
                              Text(
                                  'Jual : ${snapshot.data![i].hargajual.numberFormat(currency: true)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Stock : ${snapshot.data![i].pcs}'),
                              Text(snapshot.data![i].tglUpdate
                                      ?.formatLengkap() ??
                                  'no "update tgl" data'),
                            ],
                          ),
                        ],
                      ));
                });
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class BarangEditDialog extends StatefulWidget {
  final BarangMdl data;
  final void Function() restate;
  const BarangEditDialog(
      {super.key, required this.data, required this.restate});

  @override
  State<BarangEditDialog> createState() => _BarangEditDialogState();
}

class _BarangEditDialogState extends State<BarangEditDialog> {
  var uangFormatter = CurrencyTextInputFormatter(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  final TextEditingController namaBarang = TextEditingController();

  final TextEditingController hargaJual = TextEditingController();

  final TextEditingController jumlahStock = TextEditingController();
  @override
  void initState() {
    namaBarang.text = widget.data.namaBarang;
    hargaJual.text = widget.data.hargajual.toString();
    jumlahStock.text = widget.data.pcs.toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Edit',
                  textScaler: TextScaler.linear(2),
                ),
              ),
              ElevatedButton(
                onLongPress: () {
                  RepositoryProvider.of<BarangRepository>(context)
                      .delete(widget.data)
                      .then((value) => Navigator.pop(context));
                },
                onPressed: () {},
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.red),
                    foregroundColor: MaterialStatePropertyAll(Colors.white)),
                child: const Text('Hapus barang'),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: TextFormField(
                  controller: namaBarang,
                  decoration: const InputDecoration(label: Text('Nama Barang')),
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.all(8)),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: TextFormField(
                  validator: (value) {
                    if (value == null) return null;
                    if (value.isEmpty) return 'cant empty';
                    if (int.tryParse(value) == null) {
                      return 'not a valid number';
                    }
                    return null;
                  },
                  controller: hargaJual,
                  inputFormatters: [uangFormatter],
                  decoration: const InputDecoration(label: Text('Harga Jual')),
                ),
              ),
              const Padding(padding: EdgeInsets.all(8)),
              Expanded(
                child: TextFormField(
                  validator: (value) {
                    if (value == null) return null;
                    if (value.isEmpty) return 'cant empty';
                    if (int.tryParse(value) == null) {
                      return 'not a valid number';
                    }
                    return null;
                  },
                  controller: jumlahStock,
                  decoration: const InputDecoration(label: Text('Stock')),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () {
                      RepositoryProvider.of<BarangRepository>(context)
                          .edit(widget.data.copyWith(
                              tglUpdate: () => DateTime.now(),
                              hargajual: uangFormatter.getUnformattedValue(),
                              pcs: int.tryParse(jumlahStock.text),
                              namaBarang: namaBarang.text))
                          .then((value) {
                        Navigator.pop(context, true);
                        widget.restate;
                      });
                    },
                    child: const Text('Submit')),
                const Padding(padding: EdgeInsets.all(4)),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
