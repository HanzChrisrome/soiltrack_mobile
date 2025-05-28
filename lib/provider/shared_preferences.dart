import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferences {
  static const String _key = 'selected_language';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setLanguage(String language) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_key, language);
    _prefs = prefs;
  }

  static Future<String?> getLanguageAsync() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    return prefs.getString(_key) ?? 'en';
  }

  static String getLanguage() {
    if (_prefs == null) {
      throw Exception(
          'SharedPreferences not initialized! Call LanguagePreferences.init() first.');
    }
    return _prefs!.getString(_key) ?? 'en';
  }
}
