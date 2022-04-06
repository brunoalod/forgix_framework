import 'dart:async';
import 'dart:io';
import 'package:forgix_framework/database/table_schema.dart';
import 'package:forgix_framework/log/log.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class Database {
  static late sqflite.Database database;

  static late final List<TableSchema> tables = [];
  static late final int _version;
  static late final String _databaseName;
  static late final bool _logEnabled;

  static Future<void> initialize() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      sqflite.databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, '$_databaseName.db');

    final dbInitilized = await sqflite.openDatabase(
      path,
      version: _version,
      onCreate: _createDB,
      onUpgrade: _createDB,
      onDowngrade: _createDB,
    );

    database = dbInitilized;
  }

  static void configure({
    required int version,
    required String databaseName,
    List<TableSchema> tables = const [],
    bool logEnabled = true,
  }) {
    _version = version;
    _databaseName = databaseName;
    _logEnabled = logEnabled;
    Database.tables.addAll(tables);
  }

  static Future<void> clear() async {
    for (var schema in tables) {
      await schema.truncate();
    }
  }

  static void addTable(TableSchema tableSchema) {
    tables.add(tableSchema);
  }

  static void addTables(List<TableSchema> tables) {
    tables.addAll(tables);
  }

  static Future<void> _createDB(sqflite.Database db, [int? version, int? _]) async {
    database = db;

    for (TableSchema tableSchema in tables) {
      Log.when(_logEnabled, 'Dropping table ${tableSchema.name}.');
      await tableSchema.drop();

      Log.when(_logEnabled, 'Creating table ${tableSchema.name}.');
      await tableSchema.create();
    }
  }
}
