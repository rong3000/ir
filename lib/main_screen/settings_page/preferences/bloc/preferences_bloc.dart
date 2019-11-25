import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/bloc/preferences_event.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/bloc/preferences_state.dart';
import 'package:meta/meta.dart';
import 'package:intelligent_receipt/user_repository.dart';

class PreferencesBloc
    extends Bloc<PreferencesEvent, PreferencesState> {
  final UserRepository _userRepository;

  PreferencesBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  PreferencesState get initialState => NoLanguageSet();

  @override
  Stream<PreferencesState> mapEventToState(
    PreferencesEvent event,
  ) async* {

    if (event is DefaultLanguageSet) {
      yield* mapSetDefaultLangugeToState();
    } else if (event is LanguageChanged) {
      yield* _mapLanguageChangeToState();
    }
  }

  Stream<PreferencesState> mapSetDefaultLangugeToState() async* {
    yield null; //TODO: set default  language
  }

  Stream<PreferencesState> _mapLanguageChangeToState() async* {
    yield null; //TODO: change language
  }
}
