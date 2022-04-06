library scheduler;

import 'dart:async';

import 'package:forgix_framework/actions/action.dart';
import 'package:forgix_framework/log/log.dart';
import 'package:forgix_framework/store/store.dart';

abstract class ActionScheduler {
  static final List<_ScheduledAction> actions = [];
  static final List<_ScheduledActionLog> logs = [];

  static Future<void> initialize() async {
    final Map<String, dynamic>? json = await Store.get('Scheduler');

    if (json != null) {
      for (final log in json['logs']) {
        logs.add(_ScheduledActionLog.fromJson(log));
      }
    }

    Log.info('[Scheduler] Initialized heartbeat.');
    Timer.periodic(const Duration(seconds: 5), (_) {
      receiveHeartbeat();
    });
  }

  static void registerTask({
    required String id,
    required Action action,
    required Duration interval,
  }) {
    final _ScheduledAction scheduledAction = _ScheduledAction(
      id: id,
      action: action,
      interval: interval,
    );

    bool exists = actions.where((action) => action.id == scheduledAction.id).isNotEmpty;

    if (exists) {
      Log.info('[Scheduler] Attempted to register an already scheduled action.');
      return;
    }

    actions.add(scheduledAction);

    save();
  }

  static Future<void> receiveHeartbeat() async {
    //Log.info('[Scheduler] Received heartbeat.');

    for (final _ScheduledAction scheduledAction in actions) {
      _ScheduledActionLog? log;

      for (final _ScheduledActionLog item in logs) {
        if (item.id != scheduledAction.id) {
          continue;
        }

        log = item;
        break;
      }

      if (log != null) {
        final DateTime nextExecutionDate = log.executedAt.add(scheduledAction.interval);

        if (DateTime.now().isBefore(nextExecutionDate)) {
          continue;
        }
      }

      if (log != null) {
        log.executedAt = DateTime.now();
        await save();
      } else {
        log = _ScheduledActionLog(
          id: scheduledAction.id,
          executedAt: DateTime.now(),
        );

        logs.add(log);

        await save();
      }

      Log.info('[Scheduler] Running scheduled task ${scheduledAction.id}.');

      try {
        scheduledAction.action.run();
      } catch (e, s) {
        Log.error(e, s);
      }
    }
  }

  static Future<void> save() async {
    await Store.set(
      'Scheduler',
      {
        'logs': List<Map<String, dynamic>>.generate(logs.length, (index) {
          return logs[index].toJson();
        }),
      },
    );
  }
}

class _ScheduledAction {
  String id;
  Action action;
  Duration interval;

  _ScheduledAction({
    required this.id,
    required this.action,
    required this.interval,
  });
}

class _ScheduledActionLog {
  String id;
  DateTime executedAt;

  _ScheduledActionLog({
    required this.id,
    required this.executedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'executedAt': executedAt.toIso8601String(),
    };
  }

  static _ScheduledActionLog fromJson(Map json) {
    return _ScheduledActionLog(
      id: json['id'],
      executedAt: DateTime.parse(json['executedAt']),
    );
  }
}
