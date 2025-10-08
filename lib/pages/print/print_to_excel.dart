import 'dart:io';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:groom/blocs/cubit/serviceitems_cubit.dart';
import 'package:universal_html/html.dart' as html;
// import 'package:excel/excel.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/karyawan_repo.dart';
import 'package:groom/model/model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:weekly_date_picker/datetime_apis.dart';

class PrintMingguan extends StatelessWidget {
  final List<List<PerPerson>> perDay;
  final DateTime startDate;
  const PrintMingguan({
    super.key,
    required this.perDay,
    required this.startDate,
  });
  void printIncomeMingguan(BuildContext context) async {
    var karyawanListfr = await RepositoryProvider.of<KaryawanRepository>(
      context,
    ).getAllKaryawan(true);
    karyawanListfr = karyawanListfr
        .map((e) => e.aktif ? e : null)
        .nonNulls
        .toList();
    var karyawanList = karyawanListfr.map((e) => e.namaKaryawan).toList();
    var karyawanColorList = karyawanListfr
        .map(
          (e) => Color(
            int.tryParse(e.warnahex ?? '', radix: 16) ?? Colors.red.toARGB32(),
          ),
        )
        .toList();
    var karyawanColorList2 = karyawanColorList
        .map((e) => e.lighten(30))
        .toList();

    var colperPerson = RepositoryProvider.of<ServiceitemsCubit>(
      context,
    ).state.categories.map((e) => e.data()['title']).toList();
    // var excel = Excel.createExcel();
    final Workbook workbook = Workbook();

    final Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1:A2')
      ..merge()
      ..cellStyle.vAlign = VAlignType.center
      ..value = 'Date';

    ///Create Header
    for (var i = 0; i < karyawanList.length; i++) {
      sheet.getRangeByIndex(1, 2 + (i * 4), 1, 5 + (i * 4))
        ..merge()
        ..cellStyle.bold = true
        ..cellStyle.backColorRgb = karyawanColorList2[i]
        ..value = karyawanList[i];
      for (var j = 0; j < colperPerson.length; j++) {
        sheet.getRangeByIndex(2, 2 + (i * 4) + j)
          ..value = colperPerson[j]
          ..cellStyle.backColorRgb = karyawanColorList2[i];
      }
      sheet
              .getRangeByIndex(3, 2 + (i * 4), 9, 5 + (i * 4))
              .cellStyle
              .backColorRgb =
          karyawanColorList[i];
    } //end loop
    //data inserts
    for (var idx = 0; idx < 7; idx++) {
      // var element = perDay[idx];
      List<Object> insertRow = List.filled(
        (karyawanList.length * colperPerson.length) + 1,
        '0',
      );
      insertRow[0] = startDate.addDays(idx);

      // for (var e in element) {
      //   var index = karyawanList.indexWhere((e1) => e1 == e.namaKaryawan);
      //   var startIndex = 1 + (index * 4);
      //   for (var i = 0; i < colperPerson.length; i++) {
      //     var getprice =
      //         e.perCategory.firstWhere((wew) => wew.id == i).price / 1000;
      //     insertRow[startIndex + i] = getprice == 0 ? '' : getprice.toInt();
      //   }
      // }

      sheet.importList(insertRow, 3 + idx, 1, false);
    }
    sheet.getRangeByName('A1:U2').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('B3:U9').cellStyle.hAlign = HAlignType.right;
    sheet
        .getRangeByIndex(1, 1, 9, karyawanList.length * colperPerson.length + 1)
        .cellStyle
        .borders
        .all
        .lineStyle = LineStyle
        .thin;

    sheet.autoFitColumn(1);

    final List<int> bytes = workbook.saveSync();
    // return;
    if (kIsWeb) {
      // File theFile = File('Backup_${DateTime.now().day}.xlsx');
      // theFile.createSync(recursive: true);
      // theFile.writeAsBytesSync(bytes, mode: FileMode.write);
      var filebytes = Uint8List.fromList(bytes);
      var blob = html.Blob([filebytes], 'application/vnd.ms-excel', 'native');
      html.AnchorElement(
          href: html.Url.createObjectUrlFromBlob(blob).toString(),
        )
        ..setAttribute("download", "data.xlsx")
        ..click();
    } else if (Platform.isAndroid) {
      Directory docDir = await getApplicationDocumentsDirectory();
      File theFile = File('${docDir.path}/Backup_${DateTime.now().day}.xlsx');
      theFile.createSync(recursive: true);
      theFile.writeAsBytesSync(bytes, mode: FileMode.write);
      // final params = SaveFileDialogParams(sourceFilePath: theFile.path);
      // final filePath = await FlutterFileDialog.saveFile(params: params);
      // if (filePath != null) {
      var x = await OpenFilex.open(theFile.path);
      debugPrint(x.message);
      // }
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
        child: const Text('print!'),
      ),
    );
  }
}
