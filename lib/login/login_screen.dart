import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/login/login.dart';
import 'package:upgrader/upgrader.dart';

class LoginScreen extends StatelessWidget {
  final UserRepository _userRepository;

  LoginScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Upgrader().clearSavedSettings();

    // On Android, setup the Appcast.
    // On iOS, the default behavior will be to use the App Store version of
    // the app, so update the Bundle Identifier in example/ios/Runner with a
    // valid identifier already in the App Store.
    final String appcastURL =
        'https://raw.githubusercontent.com/larryaasen/upgrader/master/test/testappcast.xml';
    final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ["android"]);

    return Scaffold(
      appBar: AppBar(title: Text(allTranslations.text('words.login'))),
      body: BlocProvider<LoginBloc>(
        builder: (context) => LoginBloc(userRepository: _userRepository),
        child: LoginForm(userRepository: _userRepository),
      ),
//      UpgradeAlert(
//        appcastConfig: cfg,
//        debugLogging: true,
//        child: BlocProvider<LoginBloc>(
//          builder: (context) => LoginBloc(userRepository: _userRepository),
//          child: LoginForm(userRepository: _userRepository),
//        ),
//      ),
    );
  }
}
