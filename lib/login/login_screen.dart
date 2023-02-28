import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/login/login.dart';
import 'package:upgrader/upgrader.dart';

class LoginScreen extends StatefulWidget {
  final UserRepository _userRepository;

  LoginScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginScrenState();
  }
}

class _LoginScrenState extends State<LoginScreen> {
  UserRepository get _userRepository => widget._userRepository;

  @override
  void initState() {
    super.initState();
  }

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
      appBar: AppBar(
        title: Center(
            child: Text(allTranslations.text('words.login'), textAlign: TextAlign.center)
        ),
        actions: <Widget>[
          MaterialButton(
            padding: EdgeInsets.all(0),
            minWidth: 50.0,
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            child: new Text("English"),
            onPressed: () => {
              allTranslations.setNewLanguage('en').then((Null) {
                setState(() {
                });
              })
            },
            splashColor: Colors.redAccent,
          ),
          MaterialButton(
            padding: EdgeInsets.all(0),
            minWidth: 50.0,
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            child: new Text("中文"),
            onPressed: () => {
              allTranslations.setNewLanguage('zh').then((Null) {
                setState(() {
                });
              })
            },
            splashColor: Colors.redAccent,
          )
        ],

      ),
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

