import 'package:forgix_framework/database/query.dart';

enum WhereType { whereValue, whereColumn, whereIn, whereClause }

class Where {
  QueryCondition? condition;
  WhereType? type;
  String? column;
  String? comparator;
  dynamic value;
  void Function(WhereClause query)? callback;

  Where({
    this.condition,
    this.type,
    this.column,
    this.comparator,
    this.value,
    this.callback,
  });

  String toSql() {
    if (type == null) {
      throw Exception('Type no puede ser nulo.');
    }

    String str = '';

    if (type == WhereType.whereClause) {
      WhereClause clause = WhereClause();

      callback!(clause);

      str += '(' + clause.toSql() + ')';

      return str;
    }

    str += column!;

    if (type == WhereType.whereIn) {
      str += ' ' + _toSqlForIn();

      return str;
    }

    if (type == WhereType.whereValue) {
      str += ' $comparator ${queryValue(value)}';

      return str;
    }

    if (type == WhereType.whereColumn) {
      str += ' $comparator ${identifierValue(value)}';

      return str;
    }

    return str;
  }

  String _toSqlForIn() {
    String str = '';

    str += 'IN (';

    int count = 0;

    for (var item in value) {
      String prefix = ', ';

      if (count == 0) {
        prefix = '';
      }

      str += prefix + queryValue(item);

      count++;
    }

    str += ')';

    return str;
  }
}

class WhereClause {
  List<Where> wheres = [];

  WhereClause orWhereClause(void Function(WhereClause query) callback) {
    wheres.add(Where(
      condition: QueryCondition.or,
      type: WhereType.whereClause,
      callback: callback,
    ));

    return this;
  }

  WhereClause whereClause(void Function(WhereClause query) callback) {
    wheres.add(Where(
      condition: QueryCondition.and,
      type: WhereType.whereClause,
      callback: callback,
    ));

    return this;
  }

  WhereClause whereIn(String column, List<dynamic> value) {
    wheres.add(Where(
      column: column,
      value: value,
      condition: QueryCondition.and,
      type: WhereType.whereIn,
    ));

    return this;
  }

  WhereClause orWhereIn(String column, List<dynamic> value) {
    wheres.add(Where(
      column: column,
      value: value,
      condition: QueryCondition.and,
      type: WhereType.whereIn,
    ));

    return this;
  }

  WhereClause where(String column, String comparator, dynamic value) {
    wheres.add(Where(
      column: column,
      comparator: comparator,
      value: value,
      condition: QueryCondition.and,
      type: WhereType.whereValue,
    ));

    return this;
  }

  WhereClause orWhere(String column, String comparator, dynamic value) {
    wheres.add(Where(
      column: column,
      comparator: comparator,
      value: value,
      condition: QueryCondition.or,
      type: WhereType.whereValue,
    ));

    return this;
  }

  String toSql() {
    String sql = '';

    for (var where in wheres) {
      if (where == wheres.first) {
        sql += where.toSql();
      } else {
        if (where.condition == QueryCondition.and) {
          sql += ' AND ';
        } else if (where.condition == QueryCondition.or) {
          sql += ' OR ';
        }

        sql += where.toSql();
      }
    }

    return sql;
  }
}
