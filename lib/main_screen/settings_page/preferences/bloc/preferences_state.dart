import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PreferencesState extends Equatable {
  final String language;
  PreferencesState(this.language, [List props = const []]) : super(props);
}

class NoLanguageSet extends PreferencesState {
  NoLanguageSet(String language) : super(language);

  @override
  String toString() => 'Language Uninitialized';
}

class SetNewLanguage extends PreferencesState {
  SetNewLanguage(String language) : super(language, [language]);

  @override
  String toString() => 'New Language Preference Requested { requestedLanguage: $language }';
}

class SetNewLanguageSuccess extends PreferencesState {
  SetNewLanguageSuccess(String language) : super(language, [language]);

  @override
  String toString() => 'New Language Set Success { newLangauge: $language }';
}

class SetNewLanguageFail extends PreferencesState {
  SetNewLanguageFail(String language) : super(language, [language]);

  @override
  String toString() => 'New Language Change Failed { requestedLanguage: $language }';
}