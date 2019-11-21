import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TranslationState extends Equatable {
  TranslationState([List props = const []]) : super(props);
}

class NoLanguageSet extends TranslationState {
  @override
  String toString() => 'Language Uninitialized';
}

class SetNewLanguage extends TranslationState {
  final String newLanguagePref;

  SetNewLanguage(this.newLanguagePref) : super([newLanguagePref]);

  @override
  String toString() => 'New Language Preference Requested { requestedLanguage: $newLanguagePref }';
}

class SetNewLanguageSuccess extends TranslationState {
  final String newLanguage;

  SetNewLanguageSuccess(this.newLanguage) : super([newLanguage]);

  @override
  String toString() => 'New Language Set Success { newLangauge: $newLanguage }';
}

class SetNewLanguageFail extends TranslationState {
  final String requestedLanguage;

  SetNewLanguageFail(this.requestedLanguage) : super([requestedLanguage]);

  @override
  String toString() => 'New Language Change Failed { requestedLanguage: $requestedLanguage }';
}