import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MainScreenState extends Equatable {
  MainScreenState([List props = const []]) : super(props);
}

class NormalState extends MainScreenState {
  @override
  String toString() => 'NormalState';
}

class HomePageState extends MainScreenState {
  @override
  String toString() => 'HomePageState';
}

class ShowUnreviewedReceiptState extends MainScreenState {
  @override
  String toString() => 'ShowUnreviewedReceiptState';
}

class ShowReviewedReceiptState extends MainScreenState {
  @override
  String toString() => 'ShowReviewedReceiptState';
}
