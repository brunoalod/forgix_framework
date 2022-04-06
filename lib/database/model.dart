import 'package:forgix_framework/database/query.dart';
import 'package:forgix_framework/database/table_schema.dart';
import 'package:sqflite/sqflite.dart';

abstract class Model<T> {
  Future<void> delete() async {
    final schema = getSchema();
    final factory = getFactory();
    final json = factory.toJson(this as T);

    await Query.table(schema.name).where(schema.key, '=', json[schema.key]).delete();
  }

  Future<void> save({
    Batch? batch,
    Transaction? transaction,
  }) async {
    final schema = getSchema();
    final factory = getFactory();
    final json = factory.toJson(this as T);

    bool exists = false;

    if (json['id'] != null) {
      final count = await Query.table(schema.name).where(schema.key, '=', json['id']).count();

      if (count >= 1) {
        exists = true;
      }
    }

    if (exists) {
      await Query.table(schema.name, batch, transaction)
          .where(schema.key, '=', json[schema.key])
          .update(json);
    } else {
      await Query.table(schema.name, batch, transaction).insert(json);
    }
  }

  T copy() {
    return getFactory().fromJson(getFactory().toJson(this as T));
  }

  TableSchema getSchema();
  Query<T> getQuery();
  ModelFactory<T> getFactory();
}

abstract class ModelFactory<T> {
  T fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson(T model);

  List<T> fromList(List<dynamic>? list) {
    list = list ?? [];
    List<T> items = [];

    for (var item in list) {
      items.add(fromJson(item));
    }

    return items;
  }
}

abstract class ModelRelations<T> {
  Future<void> load();
}
