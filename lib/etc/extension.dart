import 'package:intl/intl.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as t;

NumberFormat numfor = NumberFormat("###,###", 'ID_id');

extension Uppercasing on String {
  String firstUpcase() {
    if (isNotEmpty) {
      String a = this[0].toUpperCase() + substring(1);

      return a;
    }
    return this;
  }

  String? numberFormat({bool? currency}) {
    int? a = int.tryParse(this);
    if (a != null) {
      if (currency == true) {
        return 'Rp${numfor.format(a)}';
      }
      return numfor.format(a);
    } else {
      return null;
      // throw Exception('cant parse to int');
    }
    // return this.
  }
  // ···
}

extension TanggalFormat on DateTime {
  t.Timestamp get timestampFire => t.Timestamp.fromDate(this);
  String formatLengkap() {
    initializeDateFormatting();
    DateFormat tanggalFormat = DateFormat('EEEE, d MMMM yyyy ', 'ID_id');
    return tanggalFormat.format(this);
  }

  String formatDayMonth() {
    initializeDateFormatting();
    DateFormat tanggalFormat = DateFormat('d MMM', 'ID_id');
    return tanggalFormat.format(this);
  }

  String clockOnly() {
    initializeDateFormatting();
    DateFormat tanggalFormat = DateFormat.Hm('ID_id');
    return tanggalFormat.format(this);
  }
}

extension Formatnum on num {
  String numberFormat({bool? currency}) {
    try {
      if (currency == true) {
        return 'Rp${numfor.format(this)}';
      }
      return numfor.format(this);
    } catch (e) {
      return 'parse err$e';
    }
    // return this.
  }
}
