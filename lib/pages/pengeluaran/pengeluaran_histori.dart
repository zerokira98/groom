import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/model.dart';

class HistoriPengeluaran extends StatefulWidget {
  final TipePengeluaran? sortBy;
  final bool? hidebar;
  const HistoriPengeluaran({super.key, this.sortBy, this.hidebar});

  @override
  State<HistoriPengeluaran> createState() => _HistoriPengeluaranState();
}

class _HistoriPengeluaranState extends State<HistoriPengeluaran> {
  TipePengeluaran? sortByType;
  List separatorDate = [];
  DateTime? dateTime;
  late Future<List<PengeluaranMdl>> myfuture;
  PengeluaranMdl? lastSeen;
  PengeluaranMdl? firstSeen;
  Future<List<PengeluaranMdl>> theFuture(
      {int limit = 20, bool back = false, bool next = false}) async {
    if (back) {
      return RepositoryProvider.of<PengeluaranRepository>(context)
          .getByOrder(sortByType,
              starts: dateTime, limit: limit, firstId: firstSeen)
          .then((value) {
        if (value.isNotEmpty) {
          firstSeen = value[0];
          lastSeen = value[value.length - 1];
        }
        return value;
      });
    }
    if (next) {
      return RepositoryProvider.of<PengeluaranRepository>(context)
          .getByOrder(sortByType,
              starts: dateTime, limit: limit, lastId: lastSeen)
          .then((value) {
        if (value.isNotEmpty) {
          firstSeen = value[0];
          lastSeen = value[value.length - 1];
        }
        return value;
      });
    }
    return RepositoryProvider.of<PengeluaranRepository>(context)
        .getByOrder(sortByType, starts: dateTime, limit: limit)
        .then((value) {
      if (value.isNotEmpty) {
        firstSeen = value[0];
        lastSeen = value[value.length - 1];
      }
      return value;
    });
  }

  @override
  void initState() {
    setState(() {
      sortByType = widget.sortBy;
      myfuture = theFuture();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    myfuture = theFuture(back: true);
                  });
                },
                icon: const Icon(Icons.keyboard_arrow_left_sharp)),
            IconButton(
                onPressed: () {
                  setState(() {
                    myfuture = theFuture(next: true);
                  });
                },
                icon: const Icon(Icons.keyboard_arrow_right_sharp)),
          ],
        ),
      ),
      appBar: (widget.hidebar == null || widget.hidebar == false)
          ? AppBar(title: const Text("Histori Pengeluaran"))
          : null,
      body: FutureBuilder<List<PengeluaranMdl>>(
        future: myfuture,
        builder: (context, snapshot) {
          debugPrint('setstated');
          Widget empty([String? err]) => SizedBox(
                child: Text('empty ${err ?? ''}'),
              );
          if (snapshot.hasError) return empty('error real${snapshot.error}');
          if (snapshot.hasData) {
            return Column(
              children: [
                if (widget.hidebar == null || widget.hidebar == false)
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
                          DropdownMenuItem(
                            value: TipePengeluaran.uang,
                            child: Text('Uang'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            sortByType = value;
                            myfuture = theFuture();
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
                                    myfuture = theFuture();
                                  })
                                : null);
                          },
                          child:
                              Text(dateTime?.formatLengkap() ?? 'All Dates')),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              sortByType = null;
                              dateTime = null;
                              myfuture = theFuture();
                            });
                          },
                          icon: const Icon(Icons.highlight_remove))
                    ],
                  ),
                if (snapshot.data!.isEmpty)
                  Expanded(child: Center(child: empty('array'))),
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
                                  '${e.tanggal.subtract(Duration(days: e.tanggal.weekday)).formatLengkap()} - ${e.tanggal.subtract(Durations.extralong1).formatLengkap()}'),
                            ),
                          TilePengeluaran(
                            e: e,
                            trailing: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Peringatan'),
                                  content: const Text('Yakin menghapus enrti?'),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          RepositoryProvider.of<
                                                      PengeluaranRepository>(
                                                  context)
                                              .delete(e)
                                              .then((value) {
                                            Navigator.pop(context);
                                            setState(() {
                                              myfuture = theFuture();
                                            });
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
                          ),
                        ],
                      );
                    },
                  ),
                )
              ],
            );
          }
          return empty('default');
        },
      ),
    );
  }
}

class TilePengeluaran extends StatelessWidget {
  final void Function()? trailing;
  final PengeluaranMdl e;
  const TilePengeluaran({super.key, this.trailing, required this.e});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Flushbar(
          message:
              'Tanggal post: ${e.tanggalPost?.formatDayMonth()} ${e.tanggalPost?.clockOnly()}',
          duration: const Duration(seconds: 2),
          animationDuration: Durations.long1,
        ).show(context);
        //   showDialog(
        //   context: context,
        //   builder: (context) => Dialog(
        //     child: Text(
        //         'Tanggal post: ${e.tanggalPost?.formatDayMonth()} ${e.tanggalPost?.clockOnly()}'),
        //   ),
        // );
      },
      trailing: (trailing != null)
          ? IconButton(
              onPressed: trailing,
              // onPressed: () {
              //   showDialog(
              //     context: context,
              //     builder: (context) => AlertDialog(
              //       title: const Text('Peringatan'),
              //       content: const Text('Yakin menghapus enrti?'),
              //       actions: [
              //         ElevatedButton(
              //             onPressed: () {

              //             }, child: const Text('Hapus')),
              //         ElevatedButton(
              //             onPressed: () {
              //               Navigator.pop(context);
              //             },
              //             child: const Text('Batal')),
              //       ],
              //     ),
              //   );
              // },
              icon: const Icon(Icons.delete))
          : null,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(e.namaPengeluaran.toString().firstUpcase()),
          Text(
            e.tipePengeluaran.name.toString().firstUpcase(),
            textScaler: const TextScaler.linear(0.925),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text((e.biaya * e.pcs).numberFormat(currency: true)),
          Text('${e.tanggal.formatDayMonth()} ${e.tanggal.clockOnly()}'),
        ],
      ),
    );
  }
}
