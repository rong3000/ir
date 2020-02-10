import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class NewsEvent extends Equatable {
  NewsEvent([List props = const []]) : super(props);
}

class LoadNewsItems extends NewsEvent {
  @override
  String toString() => 'Load news items';
}

class LoadNewsItemsSucess extends NewsEvent {
  @override
  String toString() => 'Load news items success';
}

class LoadNewsItemsFail extends NewsEvent {
  @override
  String toString() => 'Load news items fail';
}

class DismissNewsItems extends NewsEvent {
  @override
  String toString() => 'Dismiss news items';
}

class DismissNewsItemsSucess extends NewsEvent {
  @override
  String toString() => 'Dismiss news items success';
}

class DismissNewsItemsFail extends NewsEvent {
  @override
  String toString() => 'Dismiss news items fail';
}