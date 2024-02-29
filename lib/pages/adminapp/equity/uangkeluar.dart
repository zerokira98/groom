import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/model/model.dart';
import 'package:groom/pages/pengeluaran/pengeluaran_histori.dart';

class UangKeluarPage extends StatelessWidget {
  const UangKeluarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uang Keluar'),
      ),
      body: Column(
        children: [
          const Expanded(
              child: HistoriPengeluaran(
            sortBy: TipePengeluaran.uang,
            hidebar: true,
          )),
          InputCardKeluar()
        ],
      ),
    );
  }
}

class InputCardKeluar extends StatelessWidget {
  InputCardKeluar({super.key});
  final TextEditingController deskripsi = TextEditingController();
  final TextEditingController uang = TextEditingController();
  final uangFormatter = CurrencyTextInputFormatter(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  final GlobalKey<FormState> formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Card(
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
                ],
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          RepositoryProvider.of<PengeluaranRepository>(context)
                              .insert(PengeluaranMdl(
                                  tanggal: DateTime.now(),
                                  tanggalPost: DateTime.now(),
                                  namaPengeluaran: deskripsi.text,
                                  tipePengeluaran: TipePengeluaran.uang,
                                  pcs: 1,
                                  biaya: uangFormatter.getUnformattedValue()));
                          // .add(
                          //   EkuitasMdl(
                          //     tanggal: DateTime.now(),
                          //     uang: uangFormatter.getUnformattedValue(),
                          //     deskripsi: deskripsi.text))
                          // .then((value) =>
                          //     value == 1 ? Navigator.pop(context) : null);
                        } else {}
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
