import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:intelligent_receipt/translations/bloc/translation_event.dart';
import 'package:intelligent_receipt/translations/bloc/translation_state.dart';
import 'package:meta/meta.dart';
import 'package:intelligent_receipt/user_repository.dart';

class TranslationBloc
    extends Bloc<TranslationEvent, TranslationState> {
  final UserRepository _userRepository;

  TranslationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  TranslationState get initialState => NoLanguageSet();

  @override
  Stream<TranslationState> mapEventToState(
    TranslationEvent event,
  ) async* {

    if (event is DefaultLanguageSet) {
      yield* mapSetDefaultLangugeToState();
    } else if (event is LanguageChanged) {
      yield* _mapLanguageChangeToState();
    }
  }

  Stream<TranslationState> mapSetDefaultLangugeToState() async* {
    yield null; //TODO: set default  language
  }

  Stream<TranslationState> _mapLanguageChangeToState() async* {
    yield null; //TODO: change language
  }
}
