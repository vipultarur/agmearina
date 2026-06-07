import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
  };
  
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Dart Error: $error\n$stack');
    return true;
  };

  final prefs = await SharedPreferences.getInstance();
  runApp(MathspazzelApp(prefs: prefs));
}
