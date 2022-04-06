import 'package:flutter/cupertino.dart';
import 'package:forgix_framework/log/log.dart';
import 'package:forgix_framework/snackbar_manager/snackbar_manager.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

abstract class LauncherManager {
  static void launch(
    BuildContext context, {
    required String url,
    required String app,
  }) async {
    try {
      await url_launcher.launch(url);
    } catch (e, s) {
      if (await url_launcher.canLaunch(url)) {
        Log.error(e, s);
      } else {
        SnackBarManager.show(context, text: 'Tu dispositivo no soporta $app.');
      }
    }
  }
}
