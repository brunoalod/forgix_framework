import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

abstract class Log {
  static Future<void> clear() async {
    final File file = await getLogsFile();

    file.deleteSync();
  }

  static Future<String> get() async {
    final File file = await getLogsFile();

    return file.readAsStringSync();
  }

  static void when(bool condition, String message) {
    if (condition) {
      info(message);
    }
  }

  static void info(dynamic message) {
    if (message is Map) {
      message = jsonEncode(message);
    }

    debugPrint(getPrefix() + ' ' + message.toString());

    _log(message);
  }

  static void error(dynamic e, dynamic s) {
    info(e.toString() + '\n' + s.toString());
  }

  static void _log(String message) async {
    final File file = await getLogsFile();

    if (file.existsSync() == false) {
      file.createSync();
    }

    file.writeAsStringSync("$message\n", mode: FileMode.append);
  }

  static Future<File> getLogsFile() async {
    final Directory directory = await getApplicationSupportDirectory();

    final String path = p.join(directory.path, 'log.log');

    return File(path);
  }

  static String getPrefix() {
    return '[' + DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()) + ']';
  }
}
