import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PreferencesEvent extends Equatable {
  PreferencesEvent([List props = const []]) : super(props);
}

class DefaultLanguageSet extends PreferencesEvent {
  @override
  String toString() => 'Default Language Selected';
}

class LanguageChanged extends PreferencesEvent {
  final String preferredLanguage;

  LanguageChanged({@required this.preferredLanguage}): super([preferredLanguage]);
  
  @override
  String toString() => 'New Language Set';
}
