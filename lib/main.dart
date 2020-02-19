import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/authentication_bloc/bloc.dart';
import 'package:intelligent_receipt/login/login.dart';
import 'package:intelligent_receipt/main_screen/main_screen.dart';
import 'package:intelligent_receipt/main_screen/news/bloc/news_bloc.dart';
import 'package:intelligent_receipt/main_screen/news/bloc/news_event.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/bloc/preferences_bloc.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/bloc/preferences_event.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/bloc/preferences_state.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_bloc.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/splash_screen.dart';
import 'package:intelligent_receipt/simple_bloc_delegate.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  await userRepository.preferencesRepository.initialisePrefsInstance();
  await allTranslations.init(userRepository.preferencesRepository);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            builder: (context) =>
                AuthenticationBloc(userRepository: userRepository)
                  ..dispatch(AppStarted()),
          ),
          BlocProvider<ReceiptBloc>(
            builder: (context) => ReceiptBloc(
                receiptRepository: userRepository.receiptRepository),
          ),
          BlocProvider<PreferencesBloc>(
            builder: (context) =>
                PreferencesBloc(prefsRepository: userRepository.preferencesRepository)
                ..dispatch(SetPreferredLanguage())
          ),
          BlocProvider<NewsBloc>(
            builder: (context) =>
                NewsBloc(newsRepository: userRepository.newsRepository)
                //..dispatch(LoadNewsItems())
          ),
          BlocProvider<MainScreenBloc>(
              builder: (context) => MainScreenBloc(userRepository: userRepository),
          )
        ],
        child: App(userRepository: userRepository),
      ),
    );
  });
}

class App extends StatelessWidget {
  final UserRepository _userRepository;
  MainScreen _mainScreen;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      builder: (context) => _userRepository,
      child: BlocBuilder(
        bloc: BlocProvider.of<PreferencesBloc>(context),
        builder: (BuildContext context, PreferencesState prefsState) {
          return MaterialApp(
            routes: {
              MainScreen.routeName: (context) => _mainScreen,
            },

            home: BlocBuilder(
              bloc: BlocProvider.of<AuthenticationBloc>(context),
              builder: (BuildContext context, AuthenticationState state) {
                if (state is Uninitialized) {
                  return SplashScreen();
                }
                if (state is Unauthenticated) {
                  return LoginScreen(userRepository: _userRepository);
                }
                if (state is Authenticated) {
                  if (_mainScreen == null) {
                    _mainScreen = MainScreen(userRepository: _userRepository,
                        name: state.displayName);
                  }
                  return _mainScreen;
                }
              },
            ),
          );
        },
      ),
    );
  }
}
