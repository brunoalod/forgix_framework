import 'dart:math';

import 'package:lyra_framework/log/log.dart';
import 'package:intl/intl.dart';

int randomInt(min, max) {
  try {
    var rn = Random.secure();
    return min + rn.nextInt(max - min);
  } catch (e, s) {
    Log.error(e, s);
    var rn = Random();
    return min + rn.nextInt(max - min);
  }
}

String? parseString(Object? v, [String? def]) {
  if (v == null) return def;

  if (v is String) return v;

  var s = v.toString().trim();

  if (s.isEmpty) return def;

  return s;
}

bool? parseBool(Object? v, [bool? def]) {
  if (v == null) return def;

  if (v is bool) return v;

  if (v is num) return v > 0;

  String s;
  if (v is String) {
    s = v;
  } else {
    s = v.toString();
  }

  s = s.trim().toLowerCase();

  if (s.isEmpty) return def;

  return s == 'true' ||
      s == 'yes' ||
      s == 'ok' ||
      s == '1' ||
      s == 'y' ||
      s == 's' ||
      s == 't' ||
      s == '+';
}

double? parseDouble(Object? v, [double? def]) {
  if (v == null) return def;

  if (v is double) return v;
  if (v is num) return v.toDouble();

  String s;
  if (v is String) {
    s = v;
  } else {
    s = v.toString();
  }

  s = s.trim();

  if (s.isEmpty) return def;

  var n = double.tryParse(s);
  return n ?? def;
}

int? parseInt(Object? v, [int? def]) {
  if (v == null) return def;

  if (v is int) return v;
  if (v is num) return v.toInt();

  if (v is DateTime) return v.millisecondsSinceEpoch;

  String s;
  if (v is String) {
    s = v;
  } else {
    s = v.toString();
  }

  s = s.trim();

  if (s.isEmpty) return def;

  num? n = int.tryParse(s);

  if (n == null) {
    double? d = double.tryParse(s);
    if (d != null) {
      return d.toInt();
    }
  }

  return n as int? ?? def;
}

bool isDoubleT<T>() {
  return (1.5).toDouble() is T;
}

bool isIntT<T>() {
  return (1).toInt() is T;
}

String number(dynamic number) {
  return formatNumberWithoutZeroes(number);
}

String money(dynamic number) {
  return '\$ ' +
      NumberFormat.currency(
        locale: 'es-AR',
        symbol: '',
      ).format(number);
  //return '\$ ' + formatNumberWithoutZeroes(number);
}

String formatNumber(dynamic number) {
  return parseDouble(number, 0)!.toStringAsFixed(2);
}

String formatNumberWithoutZeroes(dynamic number) {
  String result = formatNumber(number);

  if (result.endsWith('.00')) {
    result = result.substring(0, result.length - 3);
  }

  return result;
}
