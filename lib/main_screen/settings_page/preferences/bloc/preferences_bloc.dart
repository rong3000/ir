import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:intelligent_receipt/data_model/preferences/preferences_repository.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/bloc/preferences_event.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/bloc/preferences_state.dart';
import 'package:meta/meta.dart';

class PreferencesBloc
    extends Bloc<PreferencesEvent, PreferencesState> {
  final PreferencesRepository _prefsRepository;

  PreferencesBloc({@required PreferencesRepository prefsRepository})
      : assert(prefsRepository != null),
        _prefsRepository = prefsRepository;

  @override
  PreferencesState get initialState => NoLanguageSet();

  @override
  Stream<PreferencesState> mapEventToState(
    PreferencesEvent event,
  ) async* {

    if (event is DefaultLanguageSet) {
      yield* mapSetDefaultLangugeToState();
    } else if (event is LanguageChanged) {
      yield* _mapLanguageChangeToState(event);
    }
  }

  Stream<PreferencesState> mapSetDefaultLangugeToState() async* {
    yield null; //TODO: set default  language
  }

  Stream<PreferencesState> _mapLanguageChangeToState(LanguageChanged event) async* {
    if (await _prefsRepository.setPreferredLanguage(event.preferredLanguage)){
      yield SetNewLanguageSuccess(event.preferredLanguage);
    }
    else {
      yield SetNewLanguageFail(event.preferredLanguage);
    }
  }
}
