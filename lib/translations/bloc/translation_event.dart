import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TranslationEvent extends Equatable {
  TranslationEvent([List props = const []]) : super(props);
}

class DefaultLanguageSet extends TranslationEvent {
  @override
  String toString() => 'Default Language Selected';
}

class LanguageChanged extends TranslationEvent {
  @override
  String toString() => 'New Language Set';
}
