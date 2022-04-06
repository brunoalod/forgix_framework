import 'dart:convert';
import 'package:http/http.dart';

/// Class to send http requests to the server.
/// Every request sent to the server should be through this class.
class ServerResponse {
  final Response raw;

  ServerResponse(this.raw);

  bool get passes {
    return raw.statusCode == 200 || raw.statusCode == 201;
  }

  bool get fails {
    return !passes;
  }

  Map<String, dynamic> get json {
    return jsonDecode(raw.body);
  }

  String get body {
    return raw.body;
  }

  int get httpCode {
    return raw.statusCode;
  }
}
