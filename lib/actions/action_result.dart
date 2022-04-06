class ActionResult<T> {
  bool passes;
  String? message;
  T? body;

  ActionResult({
    required this.passes,
    this.message,
    this.body,
  });

  static ActionResult success = ActionResult(
    passes: true,
  );

  static ActionResult fail = ActionResult(
    passes: false,
  );

  bool get fails {
    return !passes;
  }
}
