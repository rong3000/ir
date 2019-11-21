import 'package:shared_preferences/shared_preferences.dart';

//ISO 639-1 codes
const List<String> _supportedLanguages = ["en","zh"];
const String _defaultLanguage = "en";

class PreferencesRepository {

  SharedPreferences prefs;


  Future<void> initialisePrefsInstance() async {
    prefs = await SharedPreferences.getInstance();
  }

  String getDefaultLanguage() {
    return _defaultLanguage;
  }

  Future<bool> setPreferredLanguage(String lang) {
    if (!_supportedLanguages.contains(lang)) {
      return Future.value(false);
    }
    return this.prefs.setString('language', lang);
  } 

  String getPreferredLanguage() {
    return this.prefs.getString('language') ?? _defaultLanguage;
  } 
}
