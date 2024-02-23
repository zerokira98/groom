import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/karyawan_repo.dart';
import 'package:groom/db/pemasukan_repo.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/etc/lockscreen_keylock.dart';
import 'package:groom/model/model.dart';
import 'package:intl/intl.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class RiwayatPemasukan extends StatefulWidget {
  const RiwayatPemasukan({super.key});

  @override
  State<RiwayatPemasukan> createState() => _RiwayatPemasukanState();
}

class _RiwayatPemasukanState extends State<RiwayatPemasukan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pendapatan')),
      body: FutureBuilder(
        future: RepositoryProvider.of<PemasukanRepository>(context)
            // .getAllStruk(),
            .getStrukFiltered({
          'tanggalStart': DateTime.now(),
          'tanggalEnd': DateTime.now().add(const Duration(days: 1)),
          // 'order': 'reverse'
        }),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              // reverse: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var theData = snapshot.data![index];
                int total = 0;
                StringBuffer servicelist =
                    StringBuffer('${theData.namaKaryawan} : ');
                for (var e in theData.itemCards) {
                  servicelist.write(cardType[e.type] + ', ');
                  total += e.price * (e.pcsBarang);
                }
                return Column(
                  children: [
                    if (index >= 1 &&
                            snapshot.data![index].tanggal.day !=
                                snapshot.data![index - 1].tanggal.day ||
                        index == 0)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin:
                                    const EdgeInsets.only(bottom: 8.0, top: 8),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                  Theme.of(context).primaryColorDark,
                                  Theme.of(context).primaryColorDark,
                                  Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.45)
                                ])),
                                // color: ,
                                child: Text(
                                  theData.tanggal.formatLengkap(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ]),
                    ListTile(
                      isThreeLine: false,
                      trailing: InkWell(
                          onTap: () async {
                            var dia = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Yakin untuk menghapus?'),
                                  actions: [
                                    ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.green)),
                                        onPressed: () async {
                                          var a = await RepositoryProvider.of<
                                                  KaryawanRepository>(context)
                                              .getAllKaryawan();
                                          var pass = a
                                              .firstWhere((element) =>
                                                  element.namaKaryawan ==
                                                  theData.namaKaryawan)
                                              .password;
                                          showDialog<bool>(
                                            context: context,
                                            builder: (context) => KeyLock(
                                                tendigits: pass ?? '0',
                                                title: theData.namaKaryawan),
                                          ).then((value) {
                                            if (value != null && value) {
                                              RepositoryProvider.of<
                                                          PemasukanRepository>(
                                                      context)
                                                  .deleteStruk(theData)
                                                  .then((value) =>
                                                      Navigator.pop(
                                                          context, true));
                                            } else {}
                                          });
                                        },
                                        child: const Text('Hapus')),
                                    ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red)),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Batal')),
                                  ],
                                  content: Row(
                                    children: [
                                      const Text('Alasan : '),
                                      Expanded(
                                          child: DropdownMenu(
                                        dropdownMenuEntries: const [
                                          DropdownMenuEntry(
                                              value: 0,
                                              label: 'Salah input data'),
                                        ],
                                        initialSelection: 0,
                                        onSelected: (value) {},
                                      ))
                                    ],
                                  ),
                                );
                              },
                            );
                            if (dia != null && dia == true) {
                              setState(() {});
                            }
                          },
                          child: const Icon(Icons.delete)),
                      title: Text(servicelist.toString()),
                      subtitle: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'Total: $total (${theData.tipePembayaran.name})'),
                              Text(DateFormat.Hm('id_ID')
                                  .format(theData.tanggal)),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Text(theData.namaKaryawan),
                                    for (var e in theData.itemCards)
                                      Row(
                                        children: [
                                          Text('${cardType[e.type]} : '),
                                          Text(e.price.toString())
                                        ],
                                      ),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {
                                              generatePDF(true, theData);
                                            },
                                            child: Text('Share PDF')),
                                        ElevatedButton(
                                            onPressed: () {
                                              generatePDF(false, theData);
                                            },
                                            child: Text('Open PDF')),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            );
          } else if (snapshot.data == null) {
            return const Center(
              child: Text('Empty: null'),
            );
          } else if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Empty: no data'),
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  void generatePDF(bool share, StrukMdl theData) async {
    const MethodChannel _platformCall = MethodChannel('launchFile');
    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    document.pageSettings.size = PdfPageSize.a6;
    document.pageSettings.setMargins(8);
    //Add page to the PDF
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    print(pageSize);

    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 4);
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    headerRow.cells[0]
      ..value = 'No.'
      ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
    headerRow.cells[1]
      ..value = 'Nama'
      ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
    headerRow.cells[2]
      ..value = 'Pcs'
      ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
    headerRow.cells[3]
      ..value = 'Total'
      ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
    for (var i = 0; i < theData.itemCards.length; i++) {
      var telo = grid.rows.add();
      telo.cells[0]
        ..value = (i + 1).toString()
        ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
      telo.cells[2]
        ..value = theData.itemCards[i].pcsBarang.toString()
        ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
      telo.cells[3]
        ..value = theData.itemCards[i].price.numberFormat(currency: true)
        ..stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right)
        ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);

      telo.cells[1]
        ..value = cardType[theData.itemCards[i].type]
        ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
    }
    // grid.rows.add();
    grid.columns[0].width = 24;
    grid.columns[2].width = 24;
// Set header font.
    headerRow.style.font =
        PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    page.graphics.drawString(
        'Groom Barbershop', PdfStandardFont(PdfFontFamily.helvetica, 12),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: const Rect.fromLTWH(0, 0, 150, 20));
    page.graphics.drawString(
      'Karyawan: ' + theData.namaKaryawan,
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 12, pageSize.width, 12),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.middle),
    );
    page.graphics.drawString(
      theData.tanggal.formatLengkap() + ' ' + theData.tanggal.clockOnly(),
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 24, pageSize.width, 12),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.middle),
    );
    grid.draw(
        page: page,
        bounds: Rect.fromLTWH(
            0, 44, page.getClientSize().width, page.getClientSize().height));
    var appdoc = await getApplicationDocumentsDirectory();
// Save the document.
    var thefile = await File(join(appdoc.path, 'HelloWorld.pdf'))
        .writeAsBytes(await document.save());
    try {
      if (share) {
        Share.shareXFiles([XFile(thefile.path)]);
      } else {
        await OpenFilex.open(thefile.path).then((value) {
          print(value.message);
          return null;
        });
      }
      // print(thefile.absolute);
      // await OpenAppFile.open(thefile.path);
    } catch (e) {
      print(e);
    }
    // if (Platform.isAndroid || Platform.isIOS) {
    //   final Map<String, String> argument = <String, String>{
    //     'file_path': thefile.uri.toFilePath()
    //   };
    //   try {
    //     //ignore: unused_local_variable
    //     final Future<Map<String, String>?> result =
    //         _platformCall.invokeMethod('viewPdf', argument);
    //   } catch (e) {
    //     throw Exception(e);
    //   }
    // }
// Dispose the document.
    document.dispose();
  }
}
