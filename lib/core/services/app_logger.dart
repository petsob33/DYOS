import 'package:flutter/foundation.dart';

/// Lightweight logger that emits output only in debug builds.
class AppLogger {
  static void debug(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
