part of query;

/// Para columas
String identifierValue(String string) {
  return "'$string'";
}

/// Para valores
String queryValue(dynamic input) {
  if (input is int || input is double) {
    return input.toString();
  }

  if (input == null) {
    return 'null';
  }

  if (input is List) {
    input = jsonEncode(input);
  }

  if (input is Map) {
    input = jsonEncode(input);
  }

  String str = (input as String).replaceAll("'", "''");

  return "'$str'";
}
