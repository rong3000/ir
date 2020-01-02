import 'package:flutter/material.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

class ForgetButton extends StatelessWidget {
  final VoidCallback _onPressed;

  ForgetButton({Key key, VoidCallback onPressed})
      : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: _onPressed,
//      child: Text(allTranslations.text('app.login-screen.forget-button-label')),
      child: Text(allTranslations.text('app.login-screen.forget-password-button-label')),
    );
  }
}
