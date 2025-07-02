
import 'package:shared_preferences/shared_preferences.dart';


class LocalStorage {
  static Future<void> saveUserData({
    required String name,
    required List<String> allergies,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setStringList('user_allergies', allergies);
  }

  static Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? '',
      'allergies': prefs.getStringList('user_allergies') ?? [],
    };
  }

  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_allergies');
  }
}
