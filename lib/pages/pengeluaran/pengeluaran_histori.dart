import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/model.dart';

class HistoriPengeluaran extends StatefulWidget {
  final TipePengeluaran? sortBy;
  const HistoriPengeluaran({super.key, this.sortBy});

  @override
  State<HistoriPengeluaran> createState() => _HistoriPengeluaranState();
}

class _HistoriPengeluaranState extends State<HistoriPengeluaran> {
  TipePengeluaran? sortByType;
  List separatorDate = [];
  DateTime? dateTime;
  @override
  void initState() {
    sortByType = widget.sortBy;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Histori Pengeluaran")),
      body: FutureBuilder(
        future: RepositoryProvider.of<PengeluaranRepository>(context)
            .getByOrder(sortByType, starts: dateTime),
        builder: (context, snapshot) {
          Widget empty = const SizedBox();
          if (snapshot.hasError) return empty;
          if (snapshot.hasData) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton(
                      value: sortByType,
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Show All'),
                        ),
                        DropdownMenuItem(
                          value: TipePengeluaran.gaji,
                          child: Text('Gaji'),
                        ),
                        DropdownMenuItem(
                          value: TipePengeluaran.operasional,
                          child: Text('Operasional'),
                        ),
                        DropdownMenuItem(
                          value: TipePengeluaran.barangjual,
                          child: Text('Barang'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          sortByType = value;
                        });
                      },
                    ),
                    const Padding(padding: EdgeInsets.all(4)),
                    ElevatedButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          ).then((value) => value != null
                              ? setState(() {
                                  dateTime = value;
                                })
                              : null);
                        },
                        child: Text(dateTime?.formatLengkap() ?? 'All Dates')),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var e = snapshot.data![index];

                      var huh = DateUtils.dateOnly(e.tanggal
                          .subtract(Duration(days: e.tanggal.weekday + 7)));
                      var huhbf = index > 0
                          ? DateUtils.dateOnly(snapshot.data![index - 1].tanggal
                              .subtract(Duration(
                                  days: snapshot
                                          .data![index - 1].tanggal.weekday +
                                      7)))
                          : huh;
                      return Column(
                        children: [
                          //separator
                          if (sortByType == TipePengeluaran.gaji &&
                              (index == 0 || huh != huhbf))
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                Theme.of(context).primaryColorDark,
                                Theme.of(context).primaryColorDark,
                                Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(0.45)
                              ])),
                              child: Text(
                                  '${e.tanggal.subtract(Duration(days: e.tanggal.weekday + 6)).formatLengkap()} - ${e.tanggal.subtract(Duration(days: e.tanggal.weekday)).formatLengkap()}'),
                            ),
                          ListTile(
                            trailing: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Peringatan'),
                                      content:
                                          const Text('Yakin menghapus enrti?'),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              RepositoryProvider.of<
                                                          PengeluaranRepository>(
                                                      context)
                                                  .delete(e)
                                                  .then((value) {
                                                Navigator.pop(context);
                                                setState(() {});
                                              });
                                            },
                                            child: const Text('Hapus')),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Batal')),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.delete)),
                            title: Text(
                                e.namaPengeluaran.toString().firstUpcase()),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text((e.biaya * e.pcs)
                                    .numberFormat(currency: true)),
                                Text(e.tanggal.formatDayMonth().toString() +
                                    ' ' +
                                    e.tanggal.clockOnly()),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              ],
            );
          }
          return empty;
        },
      ),
    );
  }
}
