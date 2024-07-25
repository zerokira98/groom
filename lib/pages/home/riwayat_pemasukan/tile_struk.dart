import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/cust_repo.dart';
import 'package:groom/etc/extension.dart' as x;
import 'package:groom/model/model.dart';
import 'package:groom/pages/home/riwayat_pemasukan/print_widget.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;

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
  thisWidgetSetstate() => setState(() {});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: false,
      leading: widget.theData.tipePembayaran == TipePembayaran.qris
          ? IconButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                switch (widget.theData.midstatus) {
                  'pending' => Colors.yellow.withOpacity(0.5),
                  'settlement' => Colors.green.withOpacity(0.5),
                  'expired' => Colors.red.withOpacity(0.5),
                  String() => Colors.grey.withOpacity(0.5),
                  null => null,
                },
              )),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Status : ${widget.theData.midstatus}'),
                    content: Image.network(
                        'https://api.sandbox.midtrans.com/v2/qris/${widget.theData.midId}/qr-code'),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_2))
          : null,
      tileColor: widget.theData.fromCache != null
          ? widget.theData.fromCache!
              ? Colors.grey
              : null
          : null,
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
            TextEditingController nomorhp = TextEditingController();
            return StatefulBuilder(builder: (context, setstate) {
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
                            decoration: const InputDecoration(
                                labelText: 'No. WhatsApp'),
                            keyboardType: TextInputType.phone,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                              setstate(() {});
                            },
                          )),
                          ElevatedButton(
                              key: Key(nomorhp.text),
                              onPressed: (nomorhp.text.isEmpty)
                                  ? null
                                  : () {
                                      var idnPhone = nomorhp.text[0] == '0'
                                          ? nomorhp.text
                                              .replaceRange(0, 1, '62')
                                          : nomorhp.text;
                                      var uri =
                                          Uri.parse('https://wa.me/$idnPhone')
                                              .replace(queryParameters: {
                                        'text':
                                            'Terimakasih telah menggunakan jasa Groom Barbershop.'
                                      });
                                      // FilePicker.platform.pickFiles().then((value) {
                                      //   if (value == null) return;
                                      //   if (value.isSinglePick) {
                                      RepositoryProvider.of<CustomerRepo>(
                                              context)
                                          .addCustDate(idnPhone, DateTime.now())
                                          .then((value) {
                                        return launchUrl(uri);
                                      });
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
            });
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
      var blob = html.Blob([pdfinbytes], 'application/pdf', 'native');
      var anchorElement = html.AnchorElement(
        href: html.Url.createObjectUrlFromBlob(blob).toString(),
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
