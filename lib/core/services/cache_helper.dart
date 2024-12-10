import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static const String _userIdKey = 'userId';
  final SharedPreferences prefs;

  CacheHelper(this.prefs);

  Future<void> saveUserId(String userId) async {
    await prefs.setString(_userIdKey, userId);
  }

  String? getUserId() {
    return prefs.getString(_userIdKey);
  }

  Future<void> clearUser() async {
    await prefs.remove(_userIdKey);
  }
}
