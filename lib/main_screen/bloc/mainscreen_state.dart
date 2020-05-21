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

class GoToPageState extends MainScreenState {
  final int pageIndex;
  int subPageIndex = 0;
  GoToPageState(@required this.pageIndex, this.subPageIndex);
  @override
  String toString() => 'GoToPageState';
}
