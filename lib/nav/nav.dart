import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum PageRouteType { material, cupertino }

// ignore: unused_element
bool _isWaiting = false;

Future<bool> canTapDelay() async {
  if (_isWaiting) return false;

  _isWaiting = true;

  await Future<void>.delayed(const Duration(milliseconds: 150));

  _isWaiting = false;

  return true;
}

Future<T?> delayedAction<T>(Function callback) async {
  if (_isWaiting) return null;

  _isWaiting = true;
  await Future<void>.delayed(const Duration(milliseconds: 150));
  _isWaiting = false;

  return await callback.call();
}

abstract class Nav {
  Nav._();

  static bool isPopping = false;

  static Future<bool> maybePop<T>(
    BuildContext context, [
    T? result,
    bool delayed = true,
  ]) async {
    if (isPopping) return false;

    if (delayed) {
      isPopping = true;
      await Future<void>.delayed(const Duration(milliseconds: 150));
      isPopping = false;
    }

    return Navigator.maybePop(context, result);
  }

  static void pop<T>(
    BuildContext context, [
    T? result,
  ]) async {
    //if (isPopping) return;

    /*if (delayed) {
      isPopping = true;
      await Future<void>.delayed(const Duration(milliseconds: 150));
      isPopping = false;
    }*/

    Navigator.pop(context, result);
  }

  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    String? name,
    //bool delayed = true,
    PageRouteType transitionType = PageRouteType.material,
  }) async {
    /*if (MaterialDelayer.has('Nav.push')) {
      return null;
    }*/

    //await MaterialDelayer.delayFor('Nav.push');

    if (transitionType == PageRouteType.material) {
      return await Navigator.of(context).push<T>(
        MaterialPageRoute(
          builder: (_) => page,
          settings: RouteSettings(name: name),
        ),
      );
    } else {
      return await Navigator.of(context).push<T>(
        CupertinoPageRoute(
          builder: (_) => page,
          settings: RouteSettings(name: name),
        ),
      );
    }
  }

  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    Widget page, {
    String? name,
    bool delayed = true,
    PageRouteType transitionType = PageRouteType.material,
  }) async {
    if (transitionType == PageRouteType.material) {
      return await Navigator.of(context).pushAndRemoveUntil<T>(
        MaterialPageRoute(
          builder: (_) => page,
          settings: RouteSettings(name: name),
        ),
        (route) => false,
      );
    } else {
      return await Navigator.of(context).pushAndRemoveUntil<T>(
        CupertinoPageRoute(
          builder: (_) => page,
          settings: RouteSettings(name: name),
        ),
        (route) => false,
      );
    }
  }
}
