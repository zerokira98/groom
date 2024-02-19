import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/model/model.dart';

class TambahBarang extends StatefulWidget {
  const TambahBarang({
    super.key,
  });

  @override
  State<TambahBarang> createState() => _TambahBarangState();
}

class _TambahBarangState extends State<TambahBarang> {
  final TextEditingController namaBarang = TextEditingController();

  final TextEditingController hargaJual = TextEditingController();
  final TextEditingController hargaBeli = TextEditingController();

  final TextEditingController jumlahStock = TextEditingController();

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  @override
  void initState() {
    // namaBarang.text = widget.data.namaBarang;
    // hargaJual.text = widget.data.hargajual.toString();
    // jumlahStock.text = widget.data.pcs.toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Barang',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formkey,
          child: Column(mainAxisSize: MainAxisSize.max, children: [
            Text('tidak akan masuk ke catatan pengeluaran'),
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
                  flex: 3,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null) return null;
                      if (value.isEmpty) return 'cant empty';
                      if (int.tryParse(value) == null)
                        return 'not a valid number';
                    },
                    controller: hargaBeli,
                    decoration: InputDecoration(label: Text('Harga Beli')),
                  ),
                ),
                Padding(padding: EdgeInsets.all(4)),
                Expanded(
                  flex: 3,
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
                Padding(padding: EdgeInsets.all(4)),
                Expanded(
                  flex: 2,
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
            Expanded(child: SizedBox()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (formkey.currentState!.validate()) {
                          RepositoryProvider.of<BarangRepository>(context)
                              .add(BarangMdl(
                                  hargabeli: 0,
                                  tglUpdate: DateTime.now(),
                                  hargajual: int.parse(hargaJual.text),
                                  pcs: int.parse(jumlahStock.text),
                                  namaBarang: namaBarang.text))
                              .then((value) {
                            Navigator.pop(context, true);
                          });
                        }
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
      ),
    );
  }
}
