import 'package:forgix_framework/actions/action_result.dart';

abstract class Action<T> {
  Future<ActionResult<T>> run();
}
