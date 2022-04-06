import 'package:flutter/widgets.dart';
import 'package:forgix_framework/forgix/forgix.dart';

abstract class ExtendedState<T extends StatefulWidget> extends State<T> with RouteAware {
  @override
  @mustCallSuper
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) => afterFirstLayout(context));
  }

  @mustCallSuper
  void afterFirstLayout(BuildContext context) {
    if (mounted) {
      Forgix.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    Forgix.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}

  void render() {
    setState(() {});
  }
}
