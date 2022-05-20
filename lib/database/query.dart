library query;

import 'dart:convert';
import 'package:lyra_framework/database/database.dart';
import 'package:lyra_framework/database/join.dart';
import 'package:lyra_framework/database/order_by.dart';
import 'package:lyra_framework/database/statements.dart';
import 'package:lyra_framework/database/where.dart';
import 'package:lyra_framework/log/log.dart';
import 'package:sqflite/sqflite.dart' show Batch, Transaction;

part 'helpers.dart';

enum QueryCondition { or, and }

class Query<T> {
  static bool log = true;

  String tableName;
  Batch? batch;
  Transaction? transaction;
  T Function(Map<String, dynamic>)? transformer;

  Select? _select;
  Update? _update;
  Insert? _insert;
  Delete? _delete;
  bool? _count;

  final List<String> _groupBy = [];
  final List<OrderBy> _orderBy = [];
  final WhereClause _whereClause = WhereClause();
  final JoinClause _joinClause = JoinClause();

  int? _limit;
  int? _offset;

  Query({
    required this.tableName,
    this.transformer,
    this.batch,
    this.transaction,
  });

  static Query<Map<String, dynamic>> table(
    String tableName, [
    Batch? batch,
    Transaction? transaction,
  ]) {
    return Query<Map<String, dynamic>>(
      tableName: tableName,
      batch: batch,
      transaction: transaction,
    );
  }

  // #region JOINS

  Query<T> leftJoinClause(
    String table,
    void Function(JoinClauseInner join) callback,
  ) {
    _joinClause.leftJoinClause(table, callback);

    return this;
  }

  Query<T> joinClause(
    String table,
    void Function(JoinClauseInner join) callback,
  ) {
    _joinClause.joinClause(table, callback);

    return this;
  }

  Query<T> leftJoinSub(
    Query query,
    String alias,
    String column1,
    String column2,
  ) {
    _joinClause.leftJoinSub(query, alias, column1, column2);

    return this;
  }

  Query<T> joinSub(
    Query query,
    String alias,
    String column1,
    String column2,
  ) {
    _joinClause.joinSub(query, alias, column1, column2);

    return this;
  }

  Query<T> join(String table, String column1, String column2) {
    _joinClause.join(table, column1, column2);

    return this;
  }

  Query<T> leftJoin(String table, String column1, String column2) {
    _joinClause.join(table, column1, column2);

    return this;
  }

  // #endregion

  // #region WHERES

  Query<T> orWhereClause(void Function(WhereClause q) callback) {
    _whereClause.orWhereClause(callback);

    return this;
  }

  Query<T> whereClause(void Function(WhereClause q) callback) {
    _whereClause.whereClause(callback);

    return this;
  }

  Query<T> whereIn(String column, List<dynamic> value) {
    _whereClause.whereIn(column, value);

    return this;
  }

  Query<T> orWhereIn(String column, List<dynamic> value) {
    _whereClause.orWhereIn(column, value);

    return this;
  }

  Query<T> where(String column, String comparator, dynamic value) {
    _whereClause.where(column, comparator, value);

    return this;
  }

  Query<T> orWhere(String column, String comparator, dynamic value) {
    _whereClause.orWhere(column, comparator, value);

    return this;
  }

  // #endregion

  // #region AGREGADOS

  Query<T> select(List<String> items) {
    _update = null;
    _insert = null;
    _delete = null;
    _select = Select(items: items);

    return this;
  }

  Query<T> limit(int limit) {
    _limit = limit;

    return this;
  }

  Query<T> offset(int offset) {
    _offset = offset;

    return this;
  }

  Query<T> orderBy(String? orderBy, String? dir) {
    if (orderBy == null || dir == null) return this;

    _orderBy.add(OrderBy(column: orderBy, dir: dir));

    return this;
  }

  Query<T> groupBy(String groupBy) {
    _groupBy.add(groupBy);

    return this;
  }

  // #endregion

  // #region RETURN FUNCTIONS

  Future<List<T>> get() async {
    _update = null;
    _insert = null;
    _delete = null;

    _select ??= Select(items: []);

    String query = toSql();

    if (log) {
      Log.info('[QUERY BUILDER] Executing query...');
      Log.info(query);
    }

    List<Map<String, dynamic>> items = await Database.database.rawQuery(
      query,
    );

    if (log) {
      Log.info('[QUERY BUILDER] Query result...');
      Log.info(jsonEncode(items));
    }

    if (transformer == null) {
      return items as List<T>;
    }

    List<T> result = [];

    for (var item in items) {
      T newItem = transformer!(item);

      result.add(newItem);
    }

    return result;
  }

  Future<T?> find(dynamic id) {
    where('id', '=', id);

    return first();
  }

  Future<T?> first() async {
    limit(1);

    List<T> result = await get();

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<int> count() async {
    _count = true;

    String query = toSql();

    if (log) {
      Log.info('[QUERY BUILDER] Executing query...');
      Log.info(query);
    }

    List<Map<String, dynamic>> items = await Database.database.rawQuery(query);

    if (log) {
      Log.info('[QUERY BUILDER] Query result...');
      Log.info(jsonEncode(items));
    }

    if (items.isEmpty) {
      return 0;
    }

    return items.first['count'];
  }

  Future<String?> delete([bool sqlOnly = false]) async {
    _select = null;
    _update = null;
    _insert = null;
    _delete = Delete();

    var sql = toSql();

    if (sqlOnly) {
      return sql;
    }

    if (log) {
      Log.info('[QUERY BUILDER] Executing query...');
      Log.info(sql);
    }

    if (batch != null) {
      batch!.execute(sql);
      return null;
    }

    await Database.database.execute(sql);

    return null;
  }

  Future<String?> insert(
    dynamic values, [
    bool sqlOnly = false,
  ]) async {
    _select = null;
    _update = null;
    _delete = null;
    _insert = Insert(values: values);

    var sql = toSql();

    if (sqlOnly) {
      return sql;
    }

    if (log) {
      Log.info('[QUERY BUILDER] Executing query...');
      Log.info(sql);
    }

    if (batch != null) {
      batch!.execute(sql);
      return null;
    }

    await Database.database.execute(sql);

    return null;
  }

  Future<String?> update(
    Map<String, dynamic> values, [
    bool sqlOnly = false,
  ]) async {
    _select = null;
    _insert = null;
    _delete = null;
    _update = Update(values: values);

    var sql = toSql();

    if (sqlOnly) {
      return sql;
    }

    if (batch != null) {
      batch!.execute(sql);
      return null;
    }

    await Database.database.execute(sql);

    return null;
  }

  // #endregion

  // #region QUERIES

  String _selectSql() {
    String sql = '';

    sql = _select!.toSql();

    sql += ' FROM $tableName';

    if (_joinClause.joins.isNotEmpty) {
      sql += ' ';
      sql += _joinClause.toSql();
    }

    if (_whereClause.wheres.isNotEmpty) {
      sql += ' WHERE ';
      sql += _whereClause.toSql();
    }

    if (_groupBy.isNotEmpty) {
      sql += ' GROUP BY ' + _groupBy.join(', ');
    }

    if (_orderBy.isNotEmpty) {
      sql += ' ORDER BY ';
      for (OrderBy orderBy in _orderBy) {
        sql += '${orderBy.column} ${orderBy.dir}';
      }
    }

    if (_limit != null) {
      sql += ' LIMIT $_limit';
    }

    if (_offset != null) {
      sql += ' OFFSET $_offset';
    }

    return sql;
  }

  String _deleteSql() {
    String sql = 'DELETE FROM $tableName';

    if (_whereClause.wheres.isNotEmpty) {
      sql += ' WHERE ';
      sql += _whereClause.toSql();
    }

    if (_orderBy.isNotEmpty) {
      sql += ' ORDER BY ';
      for (OrderBy orderBy in _orderBy) {
        sql += '${orderBy.column} ${orderBy.dir}';
      }
    }

    if (_limit != null) {
      sql += ' LIMIT $_limit';
    }

    if (_offset != null) {
      sql += ' OFFSET $_offset';
    }

    return sql;
  }

  String _countSql() {
    String sql = 'SELECT COUNT(*) as count FROM $tableName';

    if (_joinClause.joins.isNotEmpty) {
      sql += ' ';
      sql += _joinClause.toSql();
    }

    if (_whereClause.wheres.isNotEmpty) {
      sql += ' WHERE ';
      sql += _whereClause.toSql();
    }

    if (_orderBy.isNotEmpty) {
      sql += ' ORDER BY ';
      for (OrderBy orderBy in _orderBy) {
        sql += '${orderBy.column} ${orderBy.dir}';
      }
    }

    if (_limit != null) {
      sql += ' LIMIT $_limit';
    }

    if (_offset != null) {
      sql += ' OFFSET $_offset';
    }

    return sql;
  }

  String _updateSql() {
    String sql = 'UPDATE $tableName SET ';

    int count = 1;
    int max = _update!.values.entries.length;
    _update!.values.forEach((key, value) {
      String separator = ', ';

      if (count == max) separator = '';

      sql += key + ' = ' + queryValue(value) + separator;

      count++;
    });

    if (_whereClause.wheres.isNotEmpty) {
      sql += ' WHERE ';
      sql += _whereClause.toSql();
    }

    return sql;
  }

  String _insertSql() {
    String str = 'INSERT INTO $tableName (';

    List<Map<String, dynamic>> values = [];

    if (_insert!.values is Map) {
      values.add(_insert!.values as Map<String, dynamic>);
    } else {
      values.addAll(_insert!.values as List<Map<String, dynamic>>);
    }

    int count = 1;

    int max = values.first.entries.length;
    values.first.forEach((key, value) {
      String separator = ', ';

      if (count == max) separator = ')';

      str += key + separator;

      count++;
    });

    str += ' VALUES';

    for (var value in values) {
      str += '(';

      count = 1;

      value.forEach((key, value) {
        String separator = ', ';

        if (count == max) separator = ')';

        str += queryValue(value) + separator;

        count++;
      });

      if (value != values.last) {
        str += ',';
      }
    }

    return str;
  }

  String toSql() {
    if (_select != null) {
      return _selectSql();
    } else if (_delete != null) {
      return _deleteSql();
    } else if (_update != null) {
      return _updateSql();
    } else if (_count != null) {
      return _countSql();
    } else if (_insert != null) {
      return _insertSql();
    } else {
      throw Exception('No se indicó una statement.');
    }
  }

  // #endregion
}
