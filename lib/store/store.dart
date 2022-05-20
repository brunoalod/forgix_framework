import 'dart:convert';

import 'package:lyra_framework/database/column_schema.dart';
import 'package:lyra_framework/database/database.dart';
import 'package:lyra_framework/database/query.dart';
import 'package:lyra_framework/database/table_schema.dart';

abstract class Store {
  static Future<void> initialize() async {
    Database.addTable(schema);
  }

  static Future<void> set(String key, dynamic value) async {
    await Query.table(schema.name).where('name', '=', key).delete();

    String data;

    if (value is Map) {
      data = jsonEncode(value);
    } else {
      data = value;
    }

    await Query.table(schema.name).insert({
      'name': key,
      'value': data,
    });
  }

  static Future<Map<String, dynamic>?> get(String key) async {
    Map<String, dynamic>? json = await Query.table(schema.name).where('name', '=', key).select([
      'name as name',
      'value as value',
    ]).first();

    if (json == null) {
      return json;
    }
    return jsonDecode(json['value']);
  }

  static TableSchema get schema {
    return TableSchema(
      name: 'stores',
      key: 'name',
      synchronize: false,
      columns: [
        ColumnSchema(
          name: 'name',
          type: ColumnSchemaType.text,
          isNullable: false,
        ),
        ColumnSchema(
          name: 'value',
          type: ColumnSchemaType.text,
          isNullable: false,
        ),
      ],
    );
  }
}
