import 'package:flutter/cupertino.dart';
import 'package:forgix_framework/database/database.dart';
import 'package:forgix_framework/scheduler/scheduler.dart';
import 'package:forgix_framework/server/server.dart';
import 'package:forgix_framework/store/store.dart';

abstract class Forgix {
  static final RouteObserver<PageRoute> routeObserver = RouteObserver();

  static Future<void> initialize() async {
    await Store.initialize();
    await Database.initialize();
    await Server.initialize();
    await ActionScheduler.initialize();
  }
}
