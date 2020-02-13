import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MainScreenEvent extends Equatable {
  MainScreenEvent([List props = const []]) : super(props);
}

class ShowUnreviewedReceiptEvent extends MainScreenEvent {
  @override
  String toString() => 'ShowUnreviewedReceiptEvent';
}

class ShowReviewedReceiptEvent extends MainScreenEvent {
  @override
  String toString() => 'ShowReviewedReceiptEvent';
}

// Reset to normal state
class ResetToNormalEvent extends MainScreenEvent {
  @override
  String toString() => 'ResetEvent';
}
