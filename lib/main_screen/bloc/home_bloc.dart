import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:intelligent_receipt/main_screen/bloc/home_event.dart';
import 'package:intelligent_receipt/main_screen/bloc/home_state.dart';
import 'package:meta/meta.dart';
import 'package:intelligent_receipt/user_repository.dart';

class HomeBloc
    extends Bloc<HomeEvent, HomeState> {
  final UserRepository _userRepository;

  HomeBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  HomeState get initialState => State1();

  @override
  Stream<HomeState> mapEventToState(
      HomeEvent event,
      ) async* {
    if (event is Event1) {
      yield* _mapEvent1ToState();
    } else if (event is Event2) {
      yield* _mapEvent2ToState();
    } else if (event is Event3) {
      yield* _mapEvent3ToState();
    }
  }

  Stream<HomeState> _mapEvent1ToState() async* {
    try {
      yield State1();
    } catch (_) {
      yield State3();
    }
  }

  Stream<HomeState> _mapEvent2ToState() async* {
    yield State2(await _userRepository.getUser());
  }

  Stream<HomeState> _mapEvent3ToState() async* {
    yield State3();
  }
}
