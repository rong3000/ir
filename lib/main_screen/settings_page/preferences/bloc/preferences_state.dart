import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PreferencesState extends Equatable {
  PreferencesState([List props = const []]) : super(props);
}

class NoLanguageSet extends PreferencesState {
  @override
  String toString() => 'Language Uninitialized';
}

class SetNewLanguage extends PreferencesState {
  final String newLanguagePref;

  SetNewLanguage(this.newLanguagePref) : super([newLanguagePref]);

  @override
  String toString() => 'New Language Preference Requested { requestedLanguage: $newLanguagePref }';
}

class SetNewLanguageSuccess extends PreferencesState {
  final String newLanguage;

  SetNewLanguageSuccess(this.newLanguage) : super([newLanguage]);

  @override
  String toString() => 'New Language Set Success { newLangauge: $newLanguage }';
}

class SetNewLanguageFail extends PreferencesState {
  final String requestedLanguage;

  SetNewLanguageFail(this.requestedLanguage) : super([requestedLanguage]);

  @override
  String toString() => 'New Language Change Failed { requestedLanguage: $requestedLanguage }';
}