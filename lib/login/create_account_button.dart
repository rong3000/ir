import 'package:flutter/material.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/register/register.dart';

class CreateAccountButton extends StatelessWidget {
  final UserRepository _userRepository;
  final bool _disableButton;

  CreateAccountButton({Key key, @required UserRepository userRepository, @required bool disableButton})
      : assert(userRepository != null),
        _userRepository = userRepository,
        _disableButton = disableButton,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        allTranslations.text('app.login-screen.create-account-label'),
      ),
      onPressed: _disableButton ? null : () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return RegisterScreen(userRepository: _userRepository);
          }),
        );
      },
    );
  }
}
