import 'dart:convert';
import 'package:lyra_framework/log/log.dart';
import 'package:http/http.dart';

/// Class to send http requests to the server.
/// Every request sent to the server should be through this class.
class ServerRequest {
  static Map<String, String> globalHeaders = {};

  Map<String, String>? headers;
  Map<String, dynamic>? params;
  String method;
  String endpoint;
  String url;
  Object? body;

  ServerRequest({
    required this.method,
    required this.endpoint,
    this.params,
    this.headers,
    this.body,
    required this.url,
  });

  Future<Response> send({bool log = true}) async {
    String newUrl = url;

    newUrl = newUrl + endpoint;

    newUrl = newUrl.replaceAll('//', '/');
    newUrl = newUrl.replaceAll(':/', '://');

    Uri requestUrl = Uri.parse(newUrl);

    if (params != null) {
      requestUrl = requestUrl.replace(queryParameters: params);
    }

    if (log) {
      Log.info(requestUrl.toString());
    }

    Response serverResponse;

    if (method == 'GET') {
      serverResponse = await get(
        requestUrl,
        headers: _getRequestHeaders(headers),
      ).timeout(const Duration(seconds: 30));
    } else if (method == 'POST') {
      serverResponse = await post(
        requestUrl,
        body: body != null ? jsonEncode(_getRequestBody(body! as Map<String, dynamic>?)) : null,
        headers: _getRequestHeaders(headers),
      ).timeout(const Duration(seconds: 30));
    } else {
      throw Exception('Invalid HTTP method.');
    }

    if (log) {
      Log.info(serverResponse.body);
    }

    return serverResponse;
  }

  static Map<String, dynamic> _getRequestBody([Map<String, dynamic>? body]) {
    Map<String, dynamic> baseBody = {};

    if (body != null) {
      baseBody.addAll(Map<String, dynamic>.from(body));
    }

    return baseBody;
  }

  /// Merges and returns base headers with extra headers.
  static Map<String, String> _getRequestHeaders([Map<String, String>? headers]) {
    Map<String, String> baseHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    baseHeaders.addAll(globalHeaders);

    return baseHeaders;
  }
}
