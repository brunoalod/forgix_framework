class Update {
  Map<String, dynamic> values;

  Update({
    required this.values,
  });
}

class Select {
  List<String> items = [];

  Select({
    required this.items,
  });

  String toSql() {
    if (items.isEmpty) {
      return 'SELECT *';

      /*throw Exception(
        'Las queries SELECT tienen que tener columnas a seleccionar.',
      );*/
    }

    String str = 'SELECT ';

    int count = 1;
    for (var item in items) {
      if (!item.contains(' as ') && !item.contains('*')) {
        throw Exception(
          'Por compatibilidad las queries SELECT tienen que tener alias.',
        );
      }

      String prefix = ', ';

      if (count == 1) {
        prefix = '';
      }

      str += prefix + item;

      count++;
    }

    return str;
  }
}

class Insert {
  dynamic values;

  Insert({required this.values});
}

class Delete {
  Delete();
}
