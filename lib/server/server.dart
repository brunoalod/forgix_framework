import 'dart:convert';
import 'package:lyra_framework/server/server_request.dart';
import 'package:lyra_framework/server/server_response.dart';
import 'package:lyra_framework/store/store.dart';
import 'package:http/http.dart';

/// Static class to connect the app with the server.
abstract class Server {
  static String? host;
  static String? url;

  static Future<void> initialize() async {
    Map<String, dynamic>? json = await Store.get('server');

    if (json == null) return;

    host = json['host'];
    url = json['url'];
  }

  /// Sends a GET request.
  static Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    Function? callback,
    bool log = true,
  }) async {
    ServerRequest request = ServerRequest(
      method: 'GET',
      endpoint: endpoint,
      params: params,
      url: url!,
    );

    Response response;

    response = await request.send(log: log);

    if (callback != null) {
      return callback(jsonDecode(response.body));
    }

    return response;
  }

  /// Sends a POST request.
  static Future<T> post<T>(
    String endpoint, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    Object? body,
    Function? callback,
  }) async {
    ServerRequest request = ServerRequest(
      method: 'POST',
      endpoint: endpoint,
      params: params,
      body: body,
      url: url!,
    );

    Response response;

    try {
      response = await request.send();
    } catch (error) {
      return Future.error(error);
    }

    if (callback != null) {
      return callback(jsonDecode(response.body));
    }

    if (T == ServerResponse) {
      return ServerResponse(response) as T;
    }

    return response as T;
  }

  static Future<void> save() async {
    await Store.set('server', {
      'host': host,
      'url': url,
    });
  }
}
