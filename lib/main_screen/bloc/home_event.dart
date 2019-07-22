import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeEvent extends Equatable {
  HomeEvent([List props = const []]) : super(props);
}

class Event1 extends HomeEvent {
  @override
  String toString() => 'Event1';
}

class Event2 extends HomeEvent {
  @override
  String toString() => 'Event2';
}

class Event3 extends HomeEvent {
  @override
  String toString() => 'Event3';
}
