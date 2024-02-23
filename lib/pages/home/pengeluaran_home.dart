import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/model.dart';

class PengeluaranHome extends StatefulWidget {
  const PengeluaranHome({super.key});

  @override
  State<PengeluaranHome> createState() => _PengeluaranHomeState();
}

class _PengeluaranHomeState extends State<PengeluaranHome> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController deskripsi = TextEditingController();

  final uangFormatter = CurrencyTextInputFormatter(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengeluaran')),
      body: Column(
        children: [
          Text(DateTime.now().formatLengkap()),
          Expanded(
              child: FutureBuilder(
            future: RepositoryProvider.of<PengeluaranRepository>(context)
                .getByKaryawan((BlocProvider.of<InputserviceBloc>(context).state
                        as InputserviceLoaded)
                    .karyawanName),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(snapshot.data![index].namaPengeluaran),
                            Text(snapshot.data![index].tanggal.clockOnly()),
                          ],
                        ),
                        subtitle: Text(snapshot.data![index].biaya
                            .numberFormat(currency: true)),
                      );
                    });
              }
              return const CircularProgressIndicator();
            },
          )),
          Card(
            elevation: 2,
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: deskripsi,
                            validator: (value) => switch (value) {
                              null => null,
                              String() when value.isEmpty => 'cant be empty',
                              String() => null,
                            },
                            decoration: const InputDecoration(
                                label: Text('Nama Pengeluaran')),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(4)),
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null) return null;
                              if (value.isEmpty) return 'cant be empty';
                              return null;
                            },
                            inputFormatters: [uangFormatter],
                            decoration: const InputDecoration(
                                label: Text('Jumlah Uang')),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            // print(uangFormatter.getUnformattedValue());
                            RepositoryProvider.of<PengeluaranRepository>(
                                    context)
                                .insert(PengeluaranMdl(
                                    tanggal: DateTime.now(),
                                    namaPengeluaran: deskripsi.text,
                                    tipePengeluaran:
                                        TipePengeluaran.operasional,
                                    pcs: 1,
                                    biaya: uangFormatter.getUnformattedValue(),
                                    karyawan:
                                        (BlocProvider.of<InputserviceBloc>(
                                                    context)
                                                .state as InputserviceLoaded)
                                            .karyawanName))
                                .then((value) {
                              setState(() {});
                            });
                          }
                        },
                        child: const Text('Submit')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
