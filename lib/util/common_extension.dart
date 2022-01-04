import 'package:flutter/material.dart';

extension SnackBarWithKey on GlobalKey<ScaffoldMessengerState> {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(String text) {
    return this.currentState!.showSnackBar(SnackBar(content: Text(text)));
  }
}