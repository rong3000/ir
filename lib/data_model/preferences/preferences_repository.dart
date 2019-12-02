import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

//ISO 639-1 codes
const List<String> _supportedLanguages = ["en","zh"];
const String _defaultLanguage = "en";
const Map<String, String> _supportedLanguageMap = {
  'en': 'English',
  'zh': '中文'
};
const String _storageKey = "IR_"; //TODO: use this
  ///
  /// Returns the list of supported locales
  ///
  //Iterable<Locale> supportedLocales() => _kSupportedLanguages.map<Locale>((lang) => Locale(lang, '')); //TODO

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
    allTranslations.setNewLanguage(lang);
    return this.prefs.setString('language', lang);
  } 

  ///
  /// Get the preferred langauge code, e.g. 'en' or 'zh'
  ///
  String getPreferredLanguage() {
    return this.prefs.getString('language') ?? _defaultLanguage;
  }

  Map<String, String> getSupportedLanguages() {
    return _supportedLanguageMap;
  }
}
