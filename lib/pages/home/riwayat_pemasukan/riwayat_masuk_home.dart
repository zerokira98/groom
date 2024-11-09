import 'dart:io';
import 'package:groom/pages/home/riwayat_pemasukan/tile_struk.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Align;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/karyawan_repo.dart';
import 'package:groom/db/pemasukan_repo.dart';
import 'package:groom/etc/extension.dart' as x;
import 'package:groom/etc/lockscreen_keylock.dart';
import 'package:groom/model/model.dart';
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
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
                    servicelist.write('${cardType[e.type]}, ');
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
                                  margin: const EdgeInsets.only(
                                      bottom: 8.0, top: 8),
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
                      TileStruk(
                        theData,
                        servicelist,
                        total: total,
                        deletefun: () async {
                          var dia = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Yakin untuk menghapus?'),
                                actions: [
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  Colors.green)),
                                      onPressed: () async {
                                        var a = await RepositoryProvider.of<
                                                KaryawanRepository>(context)
                                            .getAllKaryawan();
                                        if (context.mounted) {
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
                                                  .deleteStruk(theData);
                                              Navigator.pop(context, true);
                                            } else {}
                                          });
                                        }
                                      },
                                      child: const Text('Hapus')),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
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
                        pdf: generatePDF,
                      )
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
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  void generatePDF(bool share, StrukMdl theData) async {
    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    document.pageSettings.size = PdfPageSize.a8;
    document.pageSettings.setMargins(8);
    //Add page to the PDF
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
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
    var sumtotal = 0.0;
    for (var i = 0; i < theData.itemCards.length; i++) {
      sumtotal += theData.itemCards[i].price * theData.itemCards[i].pcsBarang;
      var telo = grid.rows.add();
      // telo.cells[0]
      //   ..value = '${i + 1}.'
      //   ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 0);
      telo.cells[1]
        ..value = theData.itemCards[i].pcsBarang.toString()
        ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 0);
      telo.cells[2]
        ..value = (theData.itemCards[i].price * theData.itemCards[i].pcsBarang)
            .numberFormat(currency: true)
        ..stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right)
        ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 0);

      telo.cells[0]
        ..value = "${cardType[theData.itemCards[i].type]} :  ${theData.itemCards[i].namaBarang}"
        ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 0);
    }
    grid.rows.add().cells[3]
      ..value = sumtotal.numberFormat(currency: true)
      ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 0);
    // grid.columns[0].width = 24;
    grid.columns[1].width = 24;
    grid.columns[2].width = 80;
// Set header font.
    headerRow.style.font =
        PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    page.graphics.drawString(
      'Groom Barbershop',
      PdfStandardFont(PdfFontFamily.helvetica, 16),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 4, pageSize.width, 20),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle),
    );
    page.graphics.drawString(
      'Jl. Gajahmada no xx',
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 20, pageSize.width, 20),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle),
    );
    page.graphics.drawString(
      'ig: groom_barbershop',
      PdfStandardFont(PdfFontFamily.helvetica, 8),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 30, pageSize.width, 20),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle),
    );
    page.graphics.drawString(
      'Karyawan: ${theData.namaKaryawan}',
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 72, pageSize.width, 12),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.middle),
    );
    page.graphics.drawString(
      '${theData.tanggal.formatLengkap()} ${theData.tanggal.clockOnly()}',
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 60, pageSize.width, 12),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.middle),
    );
    var drawed = grid.draw(
        page: page,
        bounds: Rect.fromLTWH(
            0, 88, page.getClientSize().width, page.getClientSize().height));

    page.graphics.drawString(
      'terimakasih~!',
      PdfStandardFont(PdfFontFamily.helvetica, 8),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, drawed!.bounds.bottom + 8, pageSize.width, 20),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle),
    );
    var appdoc = await getApplicationDocumentsDirectory();
// Save the document.
    var thefile = await File(join(appdoc.path, 'invoice.pdf'))
        .writeAsBytes(await document.save());
    if (kIsWeb) {
      var blob = html.Blob(
          thefile.readAsBytesSync().toList(), 'application/pdf', 'native');
      var anchorElement = html.AnchorElement(
        href: html.Url.createObjectUrlFromBlob(blob).toString(),
      )
        ..setAttribute("download", "data.txt")
        ..click();
    } else {
      try {
        if (share) {
          Share.shareXFiles([XFile(thefile.path)]);
        } else {
          await OpenFilex.open(thefile.path).then((value) {
            debugPrint(value.message);
            return null;
          });
        }
        // debugPrint(thefile.absolute);
        // await OpenAppFile.open(thefile.path);
      } catch (e) {
        debugPrint(e.toString());
      }
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
