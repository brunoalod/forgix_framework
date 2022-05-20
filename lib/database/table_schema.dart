import 'package:lyra_framework/database/column_schema.dart';
import 'package:lyra_framework/database/database.dart';

class TableSchema {
  String name;
  String key;
  bool synchronize;
  List<ColumnSchema> columns;

  TableSchema({
    required this.columns,
    required this.name,
    required this.key,
    this.synchronize = true,
  });

  Future<void> truncate() async {
    return await Database.database.execute('DELETE FROM ' + name);
  }

  Future<void> drop() async {
    return await Database.database.execute('DROP TABLE IF EXISTS ' + name);
  }

  Future<void> create() async {
    String str = 'CREATE TABLE IF NOT EXISTS $name (';

    int count = 0;
    for (var column in columns) {
      String columnNullable = column.isNullable ? 'NULL' : 'NOT NULL';

      str +=
          '${column.name} ${column.type.toString().split('.').last.toUpperCase()} $columnNullable';

      if (count + 1 != columns.length) str += ',\n';
      count++;
    }

    str += ')';

    return await Database.database.execute(str);
  }
}
