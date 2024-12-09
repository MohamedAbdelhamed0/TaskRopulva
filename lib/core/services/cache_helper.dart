


import 'package:shared_preferences/shared_preferences.dart';


class CacheHelper{
  CacheHelper._internal();

  static  final CacheHelper _instance = CacheHelper._internal();

  factory CacheHelper() => _instance;

  static late SharedPreferences  _sharedPreferences;
  static Future<void> init()async {
    _sharedPreferences=await SharedPreferences.getInstance();
  }


  static dynamic getData({
    required String key,
  }){
    return _sharedPreferences.get(key);
  }

  static  Future<bool> saveData({
    required String key,
    required dynamic value,
  })async {
    if(value is String) return await _sharedPreferences.setString(key, value);
    if(value is bool) return await _sharedPreferences.setBool(key, value);
    if(value is int) return await _sharedPreferences.setInt(key, value);
    if(value is double) return await _sharedPreferences.setDouble(key, value);
    return await _sharedPreferences.setStringList(key, value);

  }

  static Future<bool> removeData({
    required String key,
  })async{
    return await _sharedPreferences.remove(key);
  }

  static Future<bool> clear()async{
    return await _sharedPreferences.clear();
  }

}


