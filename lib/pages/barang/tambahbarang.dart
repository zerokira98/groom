import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/barang_repo.dart';
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
  var uangFormatter = CurrencyTextInputFormatter.currency(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  var uangFormatter2 = CurrencyTextInputFormatter.currency(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

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
        title: const Text(
          'Tambah Barang',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formkey,
          child: Column(mainAxisSize: MainAxisSize.max, children: [
            const Text('tidak akan masuk ke catatan pengeluaran'),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: namaBarang,
                    decoration:
                        const InputDecoration(label: Text('Nama Barang')),
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(8)),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null) return null;
                      if (value.isEmpty) return 'cant empty';
                      if (uangFormatter
                              .getUnformattedValue()
                              .toString()
                              .length <
                          2) {
                        return 'too small';
                      }
                      return null;
                    },
                    controller: hargaBeli,
                    inputFormatters: [uangFormatter],
                    decoration:
                        const InputDecoration(label: Text('Harga Beli')),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(4)),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null) return null;
                      if (value.isEmpty) return 'cant empty';
                      if (uangFormatter2
                              .getUnformattedValue()
                              .toString()
                              .length <
                          2) {
                        return 'too small';
                      }
                      return null;
                    },
                    controller: hargaJual,
                    inputFormatters: [uangFormatter2],
                    decoration:
                        const InputDecoration(label: Text('Harga Jual')),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(4)),
                Expanded(
                  flex: 2,
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
            const Expanded(child: SizedBox()),
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
                                  hargabeli:
                                      uangFormatter.getUnformattedValue(),
                                  tglUpdate: DateTime.now(),
                                  hargajual:
                                      uangFormatter2.getUnformattedValue(),
                                  pcs: int.parse(jumlahStock.text),
                                  namaBarang: namaBarang.text))
                              .then((value) {
                            Navigator.pop(context, true);
                          });
                        }
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
      ),
    );
  }
}
