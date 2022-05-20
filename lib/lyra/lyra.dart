import 'package:flutter/cupertino.dart';
import 'package:lyra_framework/database/database.dart';
import 'package:lyra_framework/scheduler/scheduler.dart';
import 'package:lyra_framework/server/server.dart';
import 'package:lyra_framework/store/store.dart';

abstract class Lyra {
  static final RouteObserver<PageRoute> routeObserver = RouteObserver();

  static Future<void> initialize() async {
    await Store.initialize();
    await Database.initialize();
    await Server.initialize();
    await ActionScheduler.initialize();
  }
}
