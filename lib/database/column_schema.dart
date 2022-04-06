enum ColumnSchemaType {
  autoincrement,
  integer,
  real,
  text,
  blob,
}

class ColumnSchema {
  String name;
  bool isNullable;
  ColumnSchemaType type;

  ColumnSchema({
    required this.name,
    required this.type,
    required this.isNullable,
  });
}
