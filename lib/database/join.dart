import 'package:forgix_framework/database/query.dart';
import 'package:forgix_framework/database/where.dart';

enum JoinType { normal, clause, subquery }
enum JoinDirection { left, right, center }

class Join {
  JoinType type;
  JoinDirection direction;
  String? table;
  String? column1;
  String? column2;
  String? alias;
  Query? subQuery;
  JoinClauseInner? innerClause;
  //void Function(Query query) subQueryCallback;

  Join({
    required this.type,
    required this.direction,
    this.table,
    this.alias,
    this.column1,
    this.column2,
    this.subQuery,
    this.innerClause,
  });

  String toSql() {
    String str = '';

    if (direction == JoinDirection.left) {
      str += 'LEFT JOIN';
    } else if (direction == JoinDirection.right) {
      str += 'RIGHT JOIN';
    } else {
      str += 'JOIN';
    }

    if (type == JoinType.normal) {
      str += ' $table ON $column1 = $column2';

      return str;
    }

    if (type == JoinType.subquery) {
      str += ' (' + subQuery!.toSql() + ') as $alias ON $column1 = $column2';

      return str;
    }

    //str += '$table ON $column1 = $column2';

    if (innerClause == null) {
      throw Exception('Si es clause no puede tener inner clause null');
    }

    str += ' $table ' + innerClause!.toSql();

    return str;
  }
}

class JoinClauseInner {
  String? _column1;
  String? _column2;
  final WhereClause _whereClause = WhereClause();

  JoinClauseInner on(String column1, String column2) {
    _column1 = column1;
    _column2 = column2;

    return this;
  }

  // #region WHERES

  JoinClauseInner orWhereClause(void Function(WhereClause query) callback) {
    _whereClause.orWhereClause(callback);

    return this;
  }

  JoinClauseInner whereClause(void Function(WhereClause query) callback) {
    _whereClause.whereClause(callback);

    return this;
  }

  JoinClauseInner whereIn(String column, List<dynamic> value) {
    _whereClause.whereIn(column, value);

    return this;
  }

  JoinClauseInner orWhereIn(String column, List<dynamic> value) {
    _whereClause.orWhereIn(column, value);

    return this;
  }

  JoinClauseInner where(String column, String comparator, dynamic value) {
    _whereClause.where(column, comparator, value);

    return this;
  }

  JoinClauseInner orWhere(String column, String comparator, dynamic value) {
    _whereClause.orWhere(column, comparator, value);

    return this;
  }

  // #endregion

  String toSql() {
    String sql = 'ON $_column1 = $_column2';

    if (_whereClause.wheres.isNotEmpty) {
      if (_whereClause.wheres.first.condition == QueryCondition.and) {
        sql += ' AND ';
      } else if (_whereClause.wheres.first.condition == QueryCondition.or) {
        sql += ' OR ';
      }

      sql += _whereClause.toSql();
    }

    return sql;
  }
}

class JoinClause {
  final List<Join> joins = [];

  JoinClause leftJoinClause(
    String table,
    void Function(JoinClauseInner join) callback,
  ) {
    JoinClauseInner clauseInner = JoinClauseInner();

    callback(clauseInner);

    joins.add(
      Join(
        type: JoinType.clause,
        direction: JoinDirection.left,
        table: table,
        alias: table,
        innerClause: clauseInner,
      ),
    );

    return this;
  }

  JoinClause joinClause(
    String table,
    void Function(JoinClauseInner join) callback,
  ) {
    JoinClauseInner clauseInner = JoinClauseInner();

    callback(clauseInner);

    joins.add(
      Join(
        type: JoinType.clause,
        direction: JoinDirection.center,
        table: table,
        alias: table,
        innerClause: clauseInner,
      ),
    );

    return this;
  }

  JoinClause leftJoinSub(
    Query query,
    String alias,
    String column1,
    String column2,
  ) {
    joins.add(
      Join(
        type: JoinType.subquery,
        direction: JoinDirection.left,
        column1: column1,
        column2: column2,
        alias: alias,
        subQuery: query,
      ),
    );

    return this;
  }

  JoinClause joinSub(
    Query query,
    String alias,
    String column1,
    String column2,
  ) {
    joins.add(
      Join(
        type: JoinType.subquery,
        direction: JoinDirection.center,
        column1: column1,
        column2: column2,
        alias: alias,
        subQuery: query,
      ),
    );

    return this;
  }

  JoinClause join(String table, String column1, String column2) {
    joins.add(
      Join(
        type: JoinType.normal,
        direction: JoinDirection.center,
        table: table,
        column1: column1,
        column2: column2,
      ),
    );

    return this;
  }

  JoinClause leftJoin(String table, String column1, String column2) {
    joins.add(
      Join(
        type: JoinType.normal,
        direction: JoinDirection.left,
        table: table,
        column1: column1,
        column2: column2,
      ),
    );

    return this;
  }

  String toSql() {
    String sql = '';

    int count = 1;

    for (var join in joins) {
      String prefix = ' ';

      if (count == 1) {
        prefix = '';
      }

      sql += prefix + join.toSql();
      count++;
    }

    return sql;
  }
}
