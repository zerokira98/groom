import 'dart:io';

// import 'package:excel/excel.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/model/perperson.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class PrintMingguan extends StatelessWidget {
  final List<List<PerPerson>> perDay;
  const PrintMingguan({super.key, required this.perDay});
  void printIncomeMingguan(
    BuildContext context,
  ) async {
    var karyawanListfr =
        await RepositoryProvider.of<KaryawanRepository>(context)
            .getAllKaryawan();
    karyawanListfr =
        karyawanListfr.map((e) => e.aktif ? e : null).nonNulls.toList();
    var karyawanList = karyawanListfr.map((e) => e.namaKaryawan).toList();
    // print(karyawanList);
    // var karyawanList = ['Rudy', 'Alfin', 'Febri', 'Indra', 'Yudha'];
    var karyawanColorList = [
      'DDEBF7',
      'FCE4D6',
      'E2EFDA',
      'FFF2CC',
      'EDEDED',
      'ACB9CA'
    ];
    var karyawanColorList2 = [
      '9BC2E6',
      'F4B084',
      'A9D08E',
      'FFD966',
      'D0CECE',
      'D6DCE4'
    ];
    var colperPerson = ['HC', 'S/H', 'CLR', 'GOODS'];
    // var excel = Excel.createExcel();
    final Workbook workbook = Workbook();

    final Worksheet sheet = workbook.worksheets[0];
    Directory docDir = await getApplicationDocumentsDirectory();

    sheet.getRangeByName('A1:A2')
      ..merge()
      ..cellStyle.vAlign = VAlignType.center
      ..value = 'Date';

    for (var i = 0; i < karyawanList.length; i++) {
      sheet.getRangeByIndex(1, (i + 2) + (i * 3), 1, (i + 5) + (i * 3))
        ..merge()
        ..cellStyle.bold = true
        ..cellStyle.backColorRgb =
            Color(int.parse("FF${karyawanColorList2[i]}", radix: 16))
        ..value = karyawanList[i];
      for (var j = 0; j < colperPerson.length; j++) {
        sheet.getRangeByIndex(2, i + 2 + (i * 3) + j)
          ..value = colperPerson[j]
          ..cellStyle.backColorRgb =
              Color(int.parse("FF${karyawanColorList2[i]}", radix: 16));
      }
      sheet
              .getRangeByIndex(3, (i + 2) + (i * 3), 8, (i + 5) + (i * 3))
              .cellStyle
              .backColorRgb =
          Color(int.parse("FF${karyawanColorList[i]}", radix: 16));
    } //end loop

    for (var idx = 0; idx < perDay.length; idx++) {
      var element = perDay[idx];
      List insertRow =
          List.filled((karyawanList.length * colperPerson.length) + 1, '');
      var theDate = element;
      insertRow[0] = theDate;

      for (var e in element) {
        var index = karyawanList.indexWhere(
          (e1) => e1 == e.namaKaryawan,
        );
        var startIndex = 1 + (index * 4);
        for (var i = 0; i < colperPerson.length; i++) {
          var getprice =
              e.perCategory.firstWhere((wew) => wew.type == i).price / 1000;
          insertRow[startIndex + i] =
              getprice == 0 ? '' : getprice.toInt().toString();
        }
      }

      sheet.importList(insertRow, 3 + idx, 1, false);
    }
    sheet.getRangeByName('A1:U2').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('B3:U9').cellStyle.hAlign = HAlignType.right;
    sheet.getRangeByName('A1:U9').cellStyle.borders.all.lineStyle =
        LineStyle.thin;

    sheet.autoFitColumn(1);

    final List<int> bytes = workbook.saveAsStream();
    // return;
    File theFile = File('${docDir.path}/Backup_${DateTime.now()}.xlsx');
    theFile.createSync(recursive: true);
    theFile.writeAsBytesSync(bytes, mode: FileMode.write);
    if (Platform.isAndroid) {
      final params = SaveFileDialogParams(sourceFilePath: theFile.path);
      final filePath = await FlutterFileDialog.saveFile(params: params);
      if (filePath != null) await OpenAppFile.open(filePath);
      // print(filePath);
    }
    workbook.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: TextButton(
          onPressed: () {
            printIncomeMingguan(context);
          },
          child: const Text('print!')),
    );
  }
}
