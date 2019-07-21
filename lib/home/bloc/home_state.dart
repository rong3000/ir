import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeState extends Equatable {
  HomeState([List props = const []]) : super(props);

  bool get State1 => State1;

  bool get State2 => State2;
}

class State1 extends HomeState {
  @override
  String toString() => 'State1';
}

class State2 extends HomeState {
  final String displayName;

  State2(this.displayName) : super([displayName]);

  @override
  String toString() => 'State2 { displayName: $displayName }';
}

class State3 extends HomeState {
  @override
  String toString() => 'State3';
}
