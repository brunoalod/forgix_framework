import 'package:flutter/widgets.dart';
import 'package:lyra_framework/lyra/lyra.dart';

abstract class ExtendedState<T extends StatefulWidget> extends State<T> with RouteAware {
  @override
  @mustCallSuper
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => afterFirstLayout(context));
  }

  @mustCallSuper
  void afterFirstLayout(BuildContext context) {
    if (mounted) {
      Lyra.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    Lyra.routeObserver.unsubscribe(this);
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
