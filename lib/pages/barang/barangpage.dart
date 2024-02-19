import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/DBservice.dart';
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
                  MaterialPageRoute(
                    builder: (context) => TambahBarang(),
                  )),
              icon: Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
        future: RepositoryProvider.of<BarangRepository>(context).getAll(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data!.isEmpty) return Text('Empty');
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
                          }
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
          Text(
            'Edit',
            textScaler: TextScaler.linear(2),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: TextFormField(
                  controller: namaBarang,
                  decoration: InputDecoration(label: Text('Nama Barang')),
                ),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.all(8)),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: TextFormField(
                  validator: (value) {
                    if (value == null) return null;
                    if (value.isEmpty) return 'cant empty';
                    if (int.tryParse(value) == null)
                      return 'not a valid number';
                  },
                  controller: hargaJual,
                  decoration: InputDecoration(label: Text('Harga Jual')),
                ),
              ),
              Padding(padding: EdgeInsets.all(8)),
              Expanded(
                child: TextFormField(
                  validator: (value) {
                    if (value == null) return null;
                    if (value.isEmpty) return 'cant empty';
                    if (int.tryParse(value) == null)
                      return 'not a valid number';
                  },
                  controller: jumlahStock,
                  decoration: InputDecoration(label: Text('Stock')),
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
                              hargajual: int.tryParse(hargaJual.text),
                              pcs: int.tryParse(jumlahStock.text),
                              namaBarang: namaBarang.text))
                          .then((value) {
                        Navigator.pop(context, true);
                        widget.restate;
                      });
                    },
                    child: Text('Submit')),
                Padding(padding: EdgeInsets.all(4)),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')),
              ],
            ),
          )
        ]),
      ),
    );
  }
}