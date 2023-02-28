import 'dart:async';
import 'package:bloc/bloc.dart';
import 'mainscreen_event.dart';
import 'mainscreen_state.dart';
import 'package:meta/meta.dart';
import 'package:intelligent_receipt/user_repository.dart';

class MainScreenBloc
    extends Bloc<MainScreenEvent, MainScreenState> {
  final UserRepository _userRepository;

  MainScreenBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  MainScreenState get initialState => NormalState();

  @override
  Stream<MainScreenState> mapEventToState(
      MainScreenEvent event,
      ) async* {
    if (event is GoToPageEvent) {
      yield* _mapGoToPageState(event);
    } else if (event is ResetToNormalEvent) {
      yield* _mapResetToNormalEventToState();
    }
  }

  Stream<MainScreenState> _mapGoToPageState(GoToPageEvent goToPageEvent) async* {
    yield GoToPageState(goToPageEvent.pageIndex, goToPageEvent.subPageIndex);
  }

  Stream<MainScreenState> _mapResetToNormalEventToState() async* {
    yield NormalState();
  }
}
