import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:groom/db/cust_repo.dart';
import 'package:universal_html/html.dart' as webFile;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Align;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/karyawan_repo.dart';
import 'package:groom/db/pemasukan_repo.dart';
import 'package:groom/etc/extension.dart' as x;
import 'package:groom/etc/lockscreen_keylock.dart';
import 'package:groom/model/model.dart';
import 'package:intl/intl.dart';
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
                                                  PemasukanRepository>(context)
                                              .deleteStruk(theData);
                                          Navigator.pop(context, true);
                                        } else {}
                                      });
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
                                          value: 0, label: 'Salah input data'),
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
        ..value = cardType[theData.itemCards[i].type] +
            " :  " +
            theData.itemCards[i].namaBarang
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
      var blob = webFile.Blob(
          thefile.readAsBytesSync().toList(), 'application/pdf', 'native');
      var anchorElement = webFile.AnchorElement(
        href: webFile.Url.createObjectUrlFromBlob(blob).toString(),
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

class TileStruk extends StatefulWidget {
  final void Function(bool share, StrukMdl theData)? pdf;
  final StrukMdl theData;
  final void Function()? deletefun;
  final StringBuffer serviceList;
  final int total;
  const TileStruk(this.theData, this.serviceList,
      {super.key, this.pdf, required this.total, this.deletefun});

  @override
  State<TileStruk> createState() => _TileStrukState();
}

class _TileStrukState extends State<TileStruk> {
  TextEditingController nomorhp = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: false,
      trailing: widget.deletefun != null
          ? InkWell(onTap: widget.deletefun, child: const Icon(Icons.delete))
          : null,
      title: Text(widget.serviceList.toString()),
      subtitle: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Total: ${widget.total} (${widget.theData.tipePembayaran.name})'),
              Text(DateFormat.Hm('id_ID').format(widget.theData.tanggal)),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.theData.namaKaryawan,
                          textScaler: const TextScaler.linear(1.2)),
                    ),
                    for (var e in widget.theData.itemCards)
                      Row(
                        children: [
                          Column(
                            children: [
                              Text('${cardType[e.type]} '),
                              if (e.namaBarang.isNotEmpty) Text(e.namaBarang)
                            ],
                          ),
                          const Text(' : '),
                          Text((e.price * e.pcsBarang)
                              .numberFormat(currency: true))
                        ],
                      ),
                    PrintWidget(
                      theData: widget.theData,
                    ),
                    // if (pdf != null)
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          controller: nomorhp,
                          decoration:
                              const InputDecoration(labelText: 'No. WhatsApp'),
                          keyboardType: TextInputType.phone,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null) return null;
                            if (value.isNotEmpty) {
                              bool regex = RegExp(r'^(?:[+0]9)?[0-9]{10,14}$')
                                  .hasMatch(value);
                              if (regex == false) {
                                return 'format salah/kurang dari 10digit';
                              }
                            } else {
                              return null;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        )),
                        ElevatedButton(
                            onPressed: (nomorhp.text.isEmpty)
                                ? null
                                : () {
                                    var idnPhone = nomorhp.text[0] == '0'
                                        ? nomorhp.text.replaceRange(0, 1, '62')
                                        : nomorhp.text;
                                    // FilePicker.platform.pickFiles().then((value) {
                                    //   if (value == null) return;
                                    //   if (value.isSinglePick) {
                                    RepositoryProvider.of<CustomerRepo>(context)
                                        .addCustDate(idnPhone, DateTime.now());
                                    // RepositoryProvider.of<WhatsApp>(context)
                                    //     .messagesTemplate(to: 6289509855934
                                    //         // mediaFilepath: value.paths[0],
                                    //         // mediaType: value.xFiles[0].mimeType,
                                    //         // mediaName: int.parse(idnPhone),
                                    //         )
                                    //     .then((value) {
                                    //   print(value);
                                    // }).catchError((e) => print(e));
                                    //   }
                                    // });
                                    // var urlString =

                                    // launchUrl(Uri.parse(urlString));
                                    //     .then((value) {
                                    //   print(value);
                                    // });
                                    // WhatsappShare.isInstalled().then((value) {
                                    //   if (true) {
                                    //     var idnPhone = nomorhp.text[0] == '0'
                                    //         ? nomorhp.text.replaceRange(0, 1, '62')
                                    //         : nomorhp.text;
                                    //     print(idnPhone);
                                    //     WhatsappShare.share(
                                    //             phone: idnPhone, text: 'hello')
                                    //         .then((value) {
                                    //       return null;
                                    //     }).catchError((e) {
                                    //       print(e);
                                    //     });
                                    //   }
                                    // });
                                  },
                            child: const Text('OpenWa'))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        // mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                generatePDF(true, widget.theData);
                              },
                              child: const Text('Share PDF')),
                          ElevatedButton(
                              onPressed: () {
                                generatePDF(false, widget.theData);
                              },
                              child: const Text('Open PDF')),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void generatePDF(bool share, StrukMdl theData) async {
    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    document.pageSettings.size = Size(PdfPageSize.a8.width, 420);
    document.pageSettings.setMargins(8);
    //Add page to the PDF
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 3);
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    // headerRow.cells[0]
    //   ..value = 'No.'
    //   ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
    headerRow.cells[0]
      ..value = 'Nama'
      ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
    headerRow.cells[1]
      ..value = 'Pcs'
      ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
    headerRow.cells[2]
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
        ..value = cardType[theData.itemCards[i].type] +
            " :  " +
            theData.itemCards[i].namaBarang
        ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 0);
    }
    var lastrow = grid.rows.add();
    lastrow.cells[2]
      ..value = sumtotal.numberFormat(currency: true)
      ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 0);
    lastrow.cells[0]
      ..value = theData.tipePembayaran.name.firstUpcase()
      ..style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 0);
    // grid.columns[0].width = 24;
    grid.columns[1].width = 24;
    grid.columns[2].width = 40;
// Set header font.
    headerRow.style.font =
        PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    page.graphics.drawString(
      'Groom Barbershop',
      PdfStandardFont(PdfFontFamily.helvetica, 14),
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
      theData.id ?? 'null',
      PdfStandardFont(PdfFontFamily.helvetica, 6, style: PdfFontStyle.regular),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 60, pageSize.width, 10),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.middle),
    );
    page.graphics.drawString(
      '${theData.tanggal.formatLengkap()} ${theData.tanggal.clockOnly()}',
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.regular),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 68, pageSize.width, 12),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.middle),
    );
    page.graphics.drawString(
      'Karyawan: ${theData.namaKaryawan}',
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.regular),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 80, pageSize.width, 12),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.middle),
    );
    var drawed = grid.draw(
        page: page,
        bounds: Rect.fromLTWH(
            0, 104, page.getClientSize().width, page.getClientSize().height));

    page.graphics.drawString(
      'terimakasih~!',
      PdfStandardFont(PdfFontFamily.helvetica, 8),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, drawed!.bounds.bottom + 8, pageSize.width, 20),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle),
    );
    if (kIsWeb) {
      /// Save the document.
      var pdfinbytes = Uint8List.fromList(await document.save());
      var blob = webFile.Blob([pdfinbytes], 'application/pdf', 'native');
      var anchorElement = webFile.AnchorElement(
        href: webFile.Url.createObjectUrlFromBlob(blob).toString(),
      )
        ..setAttribute("download", "data.pdf")
        ..click();
    } else {
      var appdoc = await getApplicationDocumentsDirectory();

      /// Save the document.
      var thefile = await File(join(appdoc.path, 'invoice.pdf'))
          .writeAsBytes(await document.save());
      try {
        if (share) {
          Share.shareXFiles([XFile(thefile.path)]);
        } else {
          await OpenFilex.open(thefile.path).then((value) {
            debugPrint(value.message);
            return null;
          });
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
// Dispose the document.
    document.dispose();
  }
}

class PrintWidget extends StatefulWidget {
  final StrukMdl theData;
  const PrintWidget({super.key, required this.theData});

  @override
  State<PrintWidget> createState() => _PrintWidgetState();
}

class _PrintWidgetState extends State<PrintWidget> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];

  BluetoothDevice? _device;

  bool _connected = false;
  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      debugPrint('telo platform exception');
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            debugPrint("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: error");
          });
          break;
        default:
          debugPrint(state.toString());
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        _connected = true;
      });
    }
  }

  Future show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }

  void connect(BuildContext context) {
    if (_device != null) {
      bluetooth.isConnected.then((isConnected) {
        debugPrint('here$isConnected');
        // if (isConnected == false) {
        bluetooth.connect(_device!).catchError((error) {
          debugPrint('here$error');
          setState(() => _connected = false);
        }).then((value) => setState(() => _connected = true));
        // }
      });
    } else {
      Flushbar(
        message: 'No device selected.',
        duration: const Duration(seconds: 2),
        animationDuration: Durations.long1,
      ).show(context);
      // show(context, );
    }
  }

  void disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = false);
  }

  List<DropdownMenuItem<BluetoothDevice>> getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      for (var device in _devices) {
        items.add(DropdownMenuItem(
          value: device,
          child: Text(device.name ?? ""),
        ));
      }
    }
    return items;
  }

  void printThermal(StrukMdl theData) {
    var blue = BlueThermalPrinter.instance;
    try {
      blue.isConnected.then((value) {
        if (value == null || value == false) return;
        var sumtotal = 0;

        blue.printCustom('Groom', x.Size.extraLarge.val, x.Align.center.val);
        blue.printCustom(
            'Barbershop', x.Size.extraLarge.val, x.Align.center.val);
        blue.printCustom(
            'Jl.Gajahmada no.xx', x.Size.medium.val, x.Align.center.val);
        blue.printNewLine();
        blue.printCustom(
            theData.id ?? 'null', x.Size.medium.val, x.Align.right.val);
        blue.printCustom(theData.tanggal.formatLengkap(), x.Size.medium.val,
            x.Align.right.val);
        blue.printCustom('  ${theData.tanggal.clockOnly()}', x.Size.medium.val,
            x.Align.right.val);
        blue.printCustom('Karyawan: ${theData.namaKaryawan}', x.Size.medium.val,
            x.Align.right.val);
        blue.printNewLine();
        for (var i = 0; i < theData.itemCards.length; i++) {
          sumtotal +=
              theData.itemCards[i].pcsBarang * theData.itemCards[i].price;
          var col1 = theData.itemCards[i].pcsBarang.toString();
          var col2 =
              (theData.itemCards[i].price * theData.itemCards[i].pcsBarang)
                  .numberFormat(currency: true);

          var col0 =
              "${cardType[theData.itemCards[i].type].toString().toUpperCase()} :  ${theData.itemCards[i].namaBarang.toUpperCase()}";
          blue.print3Column(col0, col1, col2, x.Size.bold.val);
        }
        blue.printNewLine();
        blue.printLeftRight("TOTAL :", sumtotal.numberFormat(currency: true),
            x.Size.boldLarge.val);

        blue.printNewLine();
        blue.printCustom("Thank You", x.Size.boldLarge.val, x.Align.center.val);
        blue.printNewLine();
        blue.printQRcode("instagram.com/groom_barbershop_pare", 200, 200,
            x.Align.center.val);
        blue.paperCut();
        return null;
      }).catchError((e) {
        debugPrint(e.toString());
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            width: 10,
          ),
          const Text(
            'Device:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            width: 30,
          ),
          Expanded(
            child: DropdownButton(
              items: getDeviceItems(),
              onChanged: (BluetoothDevice? value) =>
                  setState(() => _device = value),
              value: _device,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            onPressed: () {
              initPlatformState();
            },
            child: const Text(
              'Refresh',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _connected ? Colors.red : Colors.green),
            onPressed: () => _connected ? disconnect() : connect(context),
            child: Text(
              _connected ? 'Disconnect' : 'Connect',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      ElevatedButton(
          onPressed: () {
            printThermal(widget.theData);
            // generatePDF(false, theData);
          },
          child: const Text('Print bluetooth')),
    ]);
  }
}
