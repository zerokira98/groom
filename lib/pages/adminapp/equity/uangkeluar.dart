import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/model/model.dart';
import 'package:groom/pages/pengeluaran/pengeluaran_histori.dart';
import 'package:intl/intl.dart';

class UangKeluarPage extends StatefulWidget {
  const UangKeluarPage({super.key});

  @override
  State<UangKeluarPage> createState() => _UangKeluarPageState();
}

class _UangKeluarPageState extends State<UangKeluarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: const PreferredSize(
            preferredSize: Size.zero,
            child: Text('Masuk ke tabel pengeluaran')),
        title: const Text('Uang Keluar'),
      ),
      body: Column(
        children: [
          const Expanded(
              child: HistoriPengeluaran(
            sortBy: TipePengeluaran.uang,
            hidebar: true,
          )),
          InputCardKeluar(setstate: setState)
        ],
      ),
    );
  }
}

class InputCardKeluar extends StatefulWidget {
  final void Function(VoidCallback fn) setstate;
  const InputCardKeluar({super.key, required this.setstate});

  @override
  State<InputCardKeluar> createState() => _InputCardKeluarState();
}

class _InputCardKeluarState extends State<InputCardKeluar> {
  final TextEditingController deskripsi = TextEditingController();

  final TextEditingController uang = TextEditingController();

  final TextEditingController tanggal = TextEditingController(
      text: DateFormat.yMd('id_ID').format(DateTime.now()));

  final uangFormatter = CurrencyTextInputFormatter.currency(
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
                    keyboardType: TextInputType.number,
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
                  const Padding(padding: EdgeInsets.all(4)),
                  Expanded(
                      child: TextFormField(
                          controller: tanggal,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null) return null;
                            try {
                              DateFormat.yMd('id_ID').parseStrict(value);
                              return null;
                            } on FormatException catch (e) {
                              return e.message.toString();
                            }
                          },
                          onChanged: (value) {
                            widget.setstate(() {});
                            debugPrint(DateFormat.yMd('id_ID')
                                .tryParseStrict(value)
                                .toString());
                          },
                          decoration: InputDecoration(
                              label: const Text('Tanggal'),
                              errorMaxLines: 2,
                              suffixIcon: InkWell(
                                onTap: () {
                                  showDatePicker(
                                          context: context,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now())
                                      .then((value) {
                                    if (value != null) {
                                      widget.setstate(() {
                                        tanggal.text = DateFormat.yMd('id_ID')
                                            .format(value);
                                      });
                                    }
                                  });
                                },
                                child: const Icon(Icons.calendar_today),
                              ))))
                ],
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          RepositoryProvider.of<PengeluaranRepository>(context)
                              .insert(PengeluaranMdl(
                                  tanggal: DateFormat.yMd('id_ID')
                                      .parseStrict(tanggal.text),
                                  tanggalPost: DateTime.now(),
                                  namaPengeluaran: deskripsi.text,
                                  tipePengeluaran: TipePengeluaran.uang,
                                  pcs: 1,
                                  biaya: uangFormatter.getUnformattedValue()));
                          widget.setstate(() {
                            deskripsi.clear();
                            uang.clear();
                          });
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
