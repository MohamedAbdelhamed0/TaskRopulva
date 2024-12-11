import 'dart:developer' as developer;

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

  // Enhanced section emojis
  static const String _timeEmoji = '⏰ 📅';
  static const String _nameEmoji = '👤 🏷️';
  static const String _addEmoji = '➕ 📝';
  static const String _updateEmoji = '♻️ 🔄';
  static const String _deleteEmoji = '🗑️ ❌';
  static const String _syncEmoji = '🔄 ☁️';
  static const String _networkEmoji = '🌐 📡';
  static const String _storageEmoji = '💾 📦';

  static void success(String name, String message) {
    _printFormatted(name, 'SUCCESS', message, _green, _successEmoji);
  }

  static void error(String name, String message) {
    _printFormatted(name, 'ERROR', message, _red, _errorEmoji);
  }

  static void warning(String name, String message) {
    _printFormatted(name, 'WARNING', message, _yellow, _warningEmoji);
  }

  static void info(String name, String message) {
    _printFormatted(name, 'INFO', message, _blue, _infoEmoji);
  }

  static void debug(String name, String message) {
    _printFormatted(name, 'DEBUG', message, _magenta, _debugEmoji);
  }

  static void _printFormatted(
    String name,
    String state,
    String message,
    String color,
    String stateEmoji,
  ) {
    final timestamp = DateTime.now().toString().split('.')[0];
    final timeSection = '$_timeEmoji $timestamp';
    final nameSection = '$_nameEmoji $name';

    // Enhanced action emoji detection
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
    }

    final logMessage = '''
$color$_bold┌──────────────────────────────────────
│ $stateEmoji $state
├─ $nameSection
├─ $timeSection
└─ $actionEmoji $message$_reset
''';

    developer.log(logMessage);
  }
}
