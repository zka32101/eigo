import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Centralized logging service for the application
class LoggerService {
  static const String _tagPrefix = '[Eigo]';

  /// Log a debug message
  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag);
  }

  /// Log an info message
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag);
  }

  /// Log a warning message
  static void warning(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag);
  }

  /// Log an error message with optional exception
  static void error(String message, {String? tag, dynamic exception, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag);
    if (exception != null) {
      debugPrint('$_tagPrefix Exception: $exception');
    }
    if (stackTrace != null) {
      debugPrint('$_tagPrefix StackTrace: $stackTrace');
    }
  }

  /// Internal logging implementation
  static void _log(LogLevel level, String message, String? tag) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();
    final tagStr = tag ?? 'APP';
    final logMessage = '[$timestamp] [$levelStr] [$tagStr] $message';

    if (kDebugMode) {
      debugPrint(logMessage);
    }
  }
}
