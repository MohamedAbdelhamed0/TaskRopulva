import 'dart:developer' as developer;
import 'dart:io';

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  critical,
}

class ConsoleLogger {
  // ANSI Color and style codes
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';

  // State emojis with enhanced visibility
  static const String _successEmoji = '✅ 🎉';
  static const String _errorEmoji = '❌ 💥';
  static const String _warningEmoji = '⚠️ 🔔';
  static const String _infoEmoji = 'ℹ️ 💡';
  static const String _debugEmoji = '🔍 🐛';
  static const String _verboseEmoji = '💬 📖';

  // Enhanced section emojis
  static const String _timeEmoji = '⏰ 📅';
  static const String _nameEmoji = '👤 🏷️';
  static const String _addEmoji = '➕ 📝';
  static const String _updateEmoji = '♻️ 🔄';
  static const String _deleteEmoji = '🗑️ ❌';
  static const String _syncEmoji = '🔄 ☁️';
  static const String _networkEmoji = '🌐 📡';
  static const String _storageEmoji = '💾 📦';
  static const String _loginEmoji = '🔑 🔓';
  static const String _logoutEmoji = '🚪 🚶';
  static const String _navigationEmoji = '🧭 🗺️';

  // Logger configuration
  static LogLevel _logLevel = LogLevel.debug;
  static bool _useColor = true;
  static bool _showTimestamp = true;
  static String _logFormat =
      '$_bold┌──────────────────────────────────────\n│ {emoji} {state}\n├─ {name}\n{time}├─ {action} {message}${_reset}';
  static File? _logFile;
  static bool _outputToJSON = false;

  // Configure Logger
  static void configure({
    LogLevel? level,
    bool? useColor,
    bool? showTimestamp,
    String? format,
    String? logFilePath,
    bool? outputJSON,
  }) {
    _logLevel = level ?? _logLevel;
    _useColor = useColor ?? _useColor;
    _showTimestamp = showTimestamp ?? _showTimestamp;
    _logFormat = format ?? _logFormat;
    _outputToJSON = outputJSON ?? _outputToJSON;
    if (logFilePath != null) {
      _logFile = File(logFilePath);
    }
  }

  static void verbose(String name, String message) {
    _log(LogLevel.verbose, name, message);
  }

  static void success(String name, String message) {
    _log(LogLevel.info, name, message, _green, _successEmoji);
  }

  static void error(String name, String message) {
    _log(LogLevel.error, name, message, _red, _errorEmoji);
  }

  static void warning(String name, String message) {
    _log(LogLevel.warning, name, message, _yellow, _warningEmoji);
  }

  static void info(String name, String message) {
    _log(LogLevel.info, name, message, _blue, _infoEmoji);
  }

  static void debug(String name, String message) {
    _log(LogLevel.debug, name, message, _magenta, _debugEmoji);
  }

  static void critical(String name, String message) {
    _log(LogLevel.critical, name, message, _red, _errorEmoji);
  }

  static void _log(LogLevel level, String name, String message,
      [String? color, String? stateEmoji]) {
    if (level.index < _logLevel.index) {
      return;
    }
    final timestamp = DateTime.now().toString().split('.')[0];
    final timeSection = _showTimestamp ? '$_timeEmoji $timestamp\n├─ ' : '';
    final nameSection = '$_nameEmoji $name';

    String actionEmoji = '';
    if (message.toLowerCase().contains('add')) {
      actionEmoji = _addEmoji;
    } else if (message.toLowerCase().contains('update')) {
      actionEmoji = _updateEmoji;
    } else if (message.toLowerCase().contains('delete') ||
        message.toLowerCase().contains('remove')) {
      actionEmoji = _deleteEmoji;
    } else if (message.toLowerCase().contains('sync')) {
      actionEmoji = _syncEmoji;
    } else if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection')) {
      actionEmoji = _networkEmoji;
    } else if (message.toLowerCase().contains('storage') ||
        message.toLowerCase().contains('save')) {
      actionEmoji = _storageEmoji;
    } else if (message.toLowerCase().contains('login')) {
      actionEmoji = _loginEmoji;
    } else if (message.toLowerCase().contains('logout')) {
      actionEmoji = _logoutEmoji;
    } else if (message.toLowerCase().contains('navigation') ||
        message.toLowerCase().contains('navigate')) {
      actionEmoji = _navigationEmoji;
    }

    String? levelEmoji;

    switch (level) {
      case LogLevel.verbose:
        levelEmoji = _verboseEmoji;
        break;
      case LogLevel.info:
        levelEmoji = _infoEmoji;
        break;
      case LogLevel.error:
        levelEmoji = _errorEmoji;
        break;
      case LogLevel.debug:
        levelEmoji = _debugEmoji;
        break;
      case LogLevel.warning:
        levelEmoji = _warningEmoji;
        break;
      case LogLevel.critical:
        levelEmoji = _errorEmoji;
        break;
      default:
        levelEmoji = _infoEmoji;
        break;
    }

    Map<String, String> logData = {
      'time': timestamp,
      'state': level.name.toUpperCase(),
      'name': name,
      'message': message,
      'emoji': levelEmoji ?? '',
      'action': actionEmoji
    };

    String formattedLog = _logFormat;

    formattedLog = formattedLog.replaceAll('{emoji}', levelEmoji ?? '');
    formattedLog = formattedLog.replaceAll('{state}', level.name.toUpperCase());
    formattedLog = formattedLog.replaceAll('{name}', nameSection);
    formattedLog = formattedLog.replaceAll('{time}', timeSection);
    formattedLog = formattedLog.replaceAll('{action}', actionEmoji);
    formattedLog = formattedLog.replaceAll('{message}', message);

    final outputLog = _useColor
        ? (color == null ? formattedLog : '$color$formattedLog')
        : formattedLog;

    developer.log(outputLog);

    if (_logFile != null) {
      _saveToFile(outputLog, logData);
    }
  }

  static void _saveToFile(String message, Map<String, String> data) async {
    try {
      final sink = _logFile!.openWrite(mode: FileMode.append);
      final output = _outputToJSON ? '${data.toString()}\n' : '$message\n';
      sink.write(output);
      await sink.flush();
      await sink.close();
    } catch (e) {
      developer.log('Error saving log to file: $e');
    }
  }
}
