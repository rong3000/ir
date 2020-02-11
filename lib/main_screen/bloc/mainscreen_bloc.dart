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
  MainScreenState get initialState => HomePageState();

  @override
  Stream<MainScreenState> mapEventToState(
      MainScreenEvent event,
      ) async* {
    if (event is ShowUnreviewedReceiptEvent) {
      yield* _mapShowUnreviewedReceiptEventToState();
    } else if (event is ShowReviewedReceiptEvent) {
      yield* _mapShowReviewedReceiptEventToState();
    }
  }

  Stream<MainScreenState> _mapShowUnreviewedReceiptEventToState() async* {
    yield ShowUnreviewedReceiptState();
  }

  Stream<MainScreenState> _mapShowReviewedReceiptEventToState() async* {
    yield ShowReviewedReceiptState();
  }
}
