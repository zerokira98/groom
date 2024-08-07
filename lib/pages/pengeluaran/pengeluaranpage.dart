import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/barang_repo.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/model/model.dart';
import 'package:groom/pages/barang/barangpage.dart';
import 'package:groom/pages/pengeluaran/pengeluaran_histori.dart';
import 'package:intl/intl.dart';

import '../adminapp/rangkuman/rangkuman.dart';

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  TipePengeluaran typeValue = TipePengeluaran.operasional;

  final formKey = GlobalKey<FormState>();
  TextEditingController tanggal = TextEditingController();
  TextEditingController uangController = TextEditingController();
  TextEditingController deskripsi = TextEditingController();
  TextEditingController pcs = TextEditingController(text: '1');
  var uangFormatter = CurrencyTextInputFormatter.currency(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  valid() {
    return (uangFormatter.getUnformattedValue() != 0) &&
        (formKey.currentState?.validate() ?? false);
  }

  @override
  void initState() {
    uangFormatter.formatString('0');
    deskripsi.text = '';
    tanggal.text = DateFormat.yMd('id_ID').format(DateTime.now());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catat Pengeluaran')),
      body: Column(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: Column(children: [
                    ///Dropdown : tipe=>[@default karyawan, lainnya]
                    const Text('Jenis Pengeluaran: '),
                    DropdownButton(
                      value: typeValue,
                      items: const [
                        DropdownMenuItem(
                            value: TipePengeluaran.gaji, child: Text('Gaji')),
                        DropdownMenuItem(
                            value: TipePengeluaran.operasional,
                            child: Text('Operasional')),
                        DropdownMenuItem(
                            value: TipePengeluaran.barangjual,
                            child: Text('Barang Jual')),
                        DropdownMenuItem(
                            value: TipePengeluaran.uang, child: Text('Uang')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            typeValue = value;
                          });
                        }
                      },
                    ),
                    Text(switch (typeValue) {
                      TipePengeluaran.gaji =>
                        'Recommend to use from "Rangkuman"page.',
                      TipePengeluaran.operasional =>
                        'PLN, peralatan & perlengkapan, dll.',
                      TipePengeluaran.barangjual =>
                        'Input barang untuk dijual, masukkan nilai pembelian.',
                      TipePengeluaran.uang => 'uang.',
                    }),
                    if (typeValue.index == 0)
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      const RangkumanMingguan(),
                                ));
                          },
                          child: const Text('Rangkuman page')),
                    // const Expanded(child: SizedBox()),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                      controller: tanggal,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (value == null) return null;
                                        try {
                                          DateFormat.yMd('id_ID')
                                              .parseStrict(value);
                                          return null;
                                        } on FormatException catch (e) {
                                          return e.message.toString();
                                        }
                                      },
                                      onChanged: (value) {
                                        setState(() {});
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
                                                  setState(() {
                                                    tanggal.text =
                                                        DateFormat.yMd('id_ID')
                                                            .format(value);
                                                  });
                                                }
                                              });
                                            },
                                            child: const Icon(
                                                Icons.calendar_today),
                                          ))),
                                )),
                                Text(DateFormat.yMMMEd('id_ID').format(
                                    DateFormat.yMd('id_ID')
                                            .tryParseStrict(tanggal.text) ??
                                        DateTime.now()))
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Autocomplete(
                                    onSelected: (option) async {
                                      deskripsi.text = option;
                                      if (typeValue ==
                                          TipePengeluaran.operasional) {
                                        var a = await RepositoryProvider.of<
                                                PengeluaranRepository>(context)
                                            .getOperational(option);
                                        uangController.text =
                                            uangFormatter.formatString(
                                                a.last.biaya.toString());
                                      }
                                      if (typeValue ==
                                          TipePengeluaran.barangjual) {
                                        var a = await RepositoryProvider.of<
                                                PengeluaranRepository>(context)
                                            .getBarang(option);
                                        uangController.text =
                                            uangFormatter.formatString(
                                                a.first.biaya.toString());
                                      }
                                    },
                                    optionsBuilder: (textEditingValue) async {
                                      if (textEditingValue.text == '') {
                                        return const Iterable<String>.empty();
                                      }
                                      List<String> xxx =
                                          await RepositoryProvider.of<
                                                      PengeluaranRepository>(
                                                  context)
                                              .getAutoComplete(
                                                  textEditingValue.text,
                                                  typeValue);
                                      return xxx;
                                    },
                                    fieldViewBuilder: (context,
                                            textEditingController,
                                            focusNode,
                                            onFieldSubmitted) =>
                                        TextFormField(
                                      focusNode: focusNode,
                                      onChanged: (value) =>
                                          deskripsi.text = value,
                                      onFieldSubmitted: (value) =>
                                          onFieldSubmitted,
                                      validator: (value) {
                                        if (value == null) return null;
                                        if (value.isEmpty) {
                                          return 'Can\'t be empty';
                                        }
                                        return null;
                                      },
                                      controller: textEditingController,
                                      decoration: InputDecoration(
                                          label: Text(switch (typeValue.index) {
                                        0 => 'Nama Karyawan',
                                        1 => 'Deskripsi pengeluaran',
                                        2 => 'Nama Barang',
                                        3 => 'Deskripsi',
                                        int() => ''
                                      })),
                                    ),
                                  ),
                                ))
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: uangController,
                                        keyboardType: TextInputType.number,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: (value) {
                                          if (value == null) return null;
                                          if (value.isEmpty) {
                                            return "can't be empty";
                                          }

                                          return null;
                                        },
                                        inputFormatters: [uangFormatter],
                                        onChanged: (value) {
                                          setState(() {});
                                          // debugPrint(uangFormatter
                                          //     .getUnformattedValue());
                                        },
                                        decoration: InputDecoration(
                                            label: Text((typeValue.index == 2)
                                                ? 'Harga beli perPcs'
                                                : 'Jumlah Uang')),
                                      ),
                                    )),
                                if (typeValue.index == 2)
                                  Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: TextFormField(
                                          controller: pcs,
                                          validator: (value) {
                                            if (value == null) return null;
                                            if (value.isEmpty) {
                                              return 'Can\'t be empty';
                                            }
                                            if (int.tryParse(value) == null) {
                                              return 'not number';
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.number,
                                          // inputFormatters: [],
                                          decoration: const InputDecoration(
                                              label: Text('pcs')),
                                        ),
                                      ))
                              ],
                            ),
                            const Row(children: [
                              Text(
                                'Total:xxx',
                                textAlign: TextAlign.start,
                              ),
                            ])
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green)),
              onPressed: () async {
                ///make safety var
                if (valid()) {
                  try {
                    await RepositoryProvider.of<PengeluaranRepository>(context)
                        .insert(PengeluaranMdl(
                            tanggalPost: DateTime.now(),
                            tipePengeluaran: typeValue,
                            tanggal: DateFormat.yMd('id_ID')
                                .parseStrict(tanggal.text),
                            namaPengeluaran: deskripsi.text,
                            pcs: int.parse(pcs.text),
                            biaya: uangFormatter.getUnformattedValue()))
                        .then((value) async {
                      if (value != -1) {
                        if (typeValue == TipePengeluaran.barangjual) {
                          var find =
                              await RepositoryProvider.of<BarangRepository>(
                                      context)
                                  .find(deskripsi.text);
                          if (find.isEmpty) {
                            RepositoryProvider.of<BarangRepository>(context)
                                .add(BarangMdl(
                                    namaBarang: deskripsi.text,
                                    pcs: int.parse(pcs.text),
                                    hargabeli:
                                        uangFormatter.getUnformattedValue(),
                                    hargajual: 0))
                                .then((value) => Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => const BarangPage(),
                                    )));
                          } else {
                            RepositoryProvider.of<BarangRepository>(context)
                                .edit(find.first.copyWith(
                                    pcs: find.first.pcs + int.parse(pcs.text),
                                    hargabeli:
                                        uangFormatter.getUnformattedValue()))
                                .then((value) {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => const BarangPage(),
                                  ));
                            });
                          }
                        }
                        Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const HistoriPengeluaran(),
                            ));
                        setState(() {});
                      } else {}
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                    debugPrint(e.toString());
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('There is some invalid data')));
                }
              },
              child: const Text(
                'Submit pengeluaran uang',
                style: TextStyle(color: Colors.white),
              )),
          // ElevatedButton(
          //     onPressed: () async {
          //       debugPrint(uangFormatter.getUnformattedValue().toString());
          //     },
          //     child: const Text('try it!'))
        ],
      ),
    );
  }
}
