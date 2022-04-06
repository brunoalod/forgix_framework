import 'package:flutter/material.dart';

class ConditionalWidget extends StatelessWidget {
  final bool condition;
  final Widget? trueChild;
  final Widget? falseChild;
  final WidgetBuilder? trueBuilder;
  final WidgetBuilder? falseBuilder;

  const ConditionalWidget({
    Key? key,
    required this.condition,
    this.trueChild,
    this.falseChild,
    this.trueBuilder,
    this.falseBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (condition) {
      if (trueChild != null) {
        return trueChild!;
      } else {
        return trueBuilder!(context);
      }
    } else {
      if (falseChild != null) {
        return falseChild!;
      } else if (falseBuilder != null) {
        return falseBuilder!(context);
      } else {
        return const SizedBox();
      }
    }
  }
}
