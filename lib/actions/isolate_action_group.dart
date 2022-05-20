import 'dart:async';
import 'package:lyra_framework/actions/isolate_action.dart';
import 'package:lyra_framework/actions/isolate_action_group_result.dart';

class IsolateActionGroup {
  final _completer = Completer<IsolateActionGroupResult>();
  final int concurrents;
  final List<IsolateAction> jobs;
  final List<IsolateAction> _pendingJobs = [];
  final List<IsolateAction> _runningJobs = [];
  final List<IsolateAction> _finishedJobs = [];
  final List<dynamic> exceptions = [];
  final bool stopOnError;
  bool _hasError = false;

  IsolateActionGroup({
    required this.concurrents,
    required this.jobs,
    this.stopOnError = true,
  });

  Future<IsolateActionGroupResult> run() async {
    _pendingJobs.addAll(jobs);

    processQueue();

    return _completer.future;
  }

  void onJobFinished(IsolateAction job) {
    _runningJobs.remove(job);

    _finishedJobs.add(job);

    if (_hasError && _runningJobs.isEmpty) {
      _completer.complete(
        IsolateActionGroupResult(passes: false, exceptions: exceptions),
      );
      return;
    }

    if (_hasError) {
      return;
    }

    if (_pendingJobs.isEmpty && _runningJobs.isEmpty) {
      _completer.complete(
        IsolateActionGroupResult(passes: true, exceptions: exceptions),
      );
      return;
    }

    processQueue();
  }

  void processQueue() {
    for (var i = 0; i < _pendingJobs.length; i++) {
      final IsolateAction job = _pendingJobs[i];

      if (_runningJobs.length >= concurrents) {
        break;
      }

      _pendingJobs.removeAt(i);
      _runningJobs.add(job);

      Future future = job.run();

      future.then((value) {
        onJobFinished(job);
      }).catchError((error, stackTrace) {
        _hasError = true;
        exceptions.add(error);

        onJobFinished(job);
      });
    }
  }
}
