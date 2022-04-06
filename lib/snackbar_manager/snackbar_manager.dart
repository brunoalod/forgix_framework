import 'package:flutter/material.dart';

abstract class SnackBarManager {
  static show(
    BuildContext context, {
    required String text,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      action: SnackBarAction(label: 'CERRAR', onPressed: () {}),
      backgroundColor: Colors.white,
      elevation: 20,
      duration: const Duration(milliseconds: 2500),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    ));
  }
}
