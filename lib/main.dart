import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/authentication_bloc/bloc.dart';
import 'package:intelligent_receipt/login/login.dart';
import 'package:intelligent_receipt/main_screen/main_screen.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_bloc.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/splash_screen.dart';
import 'package:intelligent_receipt/simple_bloc_delegate.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
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
          )
        ],
        child: App(userRepository: userRepository),
      ),
    );
  });
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      builder: (context) => _userRepository,
      child: MaterialApp(
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
              return MainScreen(
                  userRepository: _userRepository, name: state.displayName);
            }
          },
        ),
      ),
    );
  }
}
