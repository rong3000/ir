import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MainScreenEvent extends Equatable {
  MainScreenEvent([List props = const []]) : super(props);
}

class GoToPageEvent extends MainScreenEvent {
  final int pageIndex;
  int subPageIndex = 0;
  GoToPageEvent(@required this.pageIndex, this.subPageIndex);

  @override
  String toString() => 'GoToPageEvent';
}

// Reset to normal state
class ResetToNormalEvent extends MainScreenEvent {
  @override
  String toString() => 'ResetEvent';
}
