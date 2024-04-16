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

  String get weekdayName {
    initializeDateFormatting();
    DateFormat tanggalFormat = DateFormat('EEE', 'ID_id');
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

enum Size {
  medium, //normal size text
  bold, //only bold text
  boldMedium, //bold with medium
  boldLarge, //bold with large
  extraLarge //extra large
}

enum Align {
  left, //ESC_ALIGN_LEFT
  center, //ESC_ALIGN_CENTER
  right, //ESC_ALIGN_RIGHT
}

extension PrintSize on Size {
  int get val {
    switch (this) {
      case Size.medium:
        return 0;
      case Size.bold:
        return 1;
      case Size.boldMedium:
        return 2;
      case Size.boldLarge:
        return 3;
      case Size.extraLarge:
        return 4;
      default:
        return 0;
    }
  }
}

extension PrintAlign on Align {
  int get val {
    switch (this) {
      case Align.left:
        return 0;
      case Align.center:
        return 1;
      case Align.right:
        return 2;
      default:
        return 0;
    }
  }
}
