import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/authentication_bloc/bloc.dart';
import 'package:intelligent_receipt/register/register.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/validators.dart';

class RegisterForm extends StatefulWidget {
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterBloc _registerBloc;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isRegisterButtonEnabled(RegisterState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _registerBloc = BlocProvider.of<RegisterBloc>(context);
//    _emailController.addListener(_onEmailChanged);
//    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _registerBloc,
      listener: (BuildContext context, RegisterState state) {
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(allTranslations.text('app.register-form.registration-in-progress-label')),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).dispatch(LoggedIn());
          Navigator.of(context).pop();

          _showMessage('Verification Email sent',
              "We have sent you the email verification, please check if it's in the SPAM mail if it cannot be found in your inbox.");
        }
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(allTranslations.text('app.register-form.registration-failed-label') + "\n" + state.message),
                    Icon(Icons.error),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      child: BlocBuilder(
        bloc: _registerBloc,
        builder: (BuildContext context, RegisterState state) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: allTranslations.text('words.email'),
                    ),
                    autocorrect: false,
                    validator: (value) {
                      return !Validators.isValidEmail(value) ? allTranslations.text('app.common.invalid-email-message') : null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: allTranslations.text('words.password'),
                    ),
                    obscureText: true,
                    autocorrect: false,
                    validator: (value) {
                      return !Validators.isValidPassword(value) ? allTranslations.text('app.common.invalid-password-message') : null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: allTranslations.text('words.re-enter-password'),
                    ),
                    obscureText: true,
                    autocorrect: false,
                    validator: (value) {
                      return (value != _passwordController.text) ? allTranslations.text('app.common.password-mismatch-message') : null;
                    },
                  ),
                  RegisterButton(
                    onPressed: _onFormSubmitted
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMessage(String title, String message) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: new Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _registerBloc.dispatch(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _registerBloc.dispatch(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    // Do a field validation
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();
    } else {
      return;
    }

    _registerBloc.dispatch(
      Submitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
