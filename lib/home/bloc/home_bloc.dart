import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/home/home.dart';
import 'package:intelligent_receipt/validators.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository _userRepository;

  HomeBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  HomeState get initialState => HomeState.empty();

  @override
  Stream<HomeState> transform(
    Stream<HomeEvent> events,
    Stream<HomeState> Function(HomeEvent event) next,
  ) {
    final observableStream = events as Observable<HomeEvent>;
    final nonDebounceStream = observableStream.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = observableStream.where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transform(nonDebounceStream.mergeWith([debounceStream]), next);
  }

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is Submitted) {
      yield* _mapFormSubmittedToState(event.email, event.password);
    }
  }

  Stream<HomeState> _mapEmailChangedToState(String email) async* {
    yield currentState.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<HomeState> _mapPasswordChangedToState(String password) async* {
    yield currentState.update(
      isPasswordValid: Validators.isValidPassword(password),
    );
  }

  Stream<HomeState> _mapFormSubmittedToState(
    String email,
    String password,
  ) async* {
    yield HomeState.loading();
    try {
      await _userRepository.signUp(
        email: email,
        password: password,
      );
      yield HomeState.success();
    } catch (_) {
      yield HomeState.failure();
    }
  }
}
