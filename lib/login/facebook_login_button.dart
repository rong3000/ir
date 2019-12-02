import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/login/login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

class FacebookLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      icon: Icon(FontAwesomeIcons.facebook, color: Colors.white),
      onPressed: () {
        BlocProvider.of<LoginBloc>(context).dispatch(
          LoginWithFacebookPressed(),
        );
      },
      label: Text(allTranslations.text('app.login-screen.fb-signin-label'), style: TextStyle(color: Colors.white)),
      color: Colors.blueAccent,
    );
  }
}
