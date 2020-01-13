// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


// This file feels very unfinished and no trtanslations have been done - RB

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/hotmail.dart';

import '../../../user_repository.dart';

class ContactUs extends StatefulWidget {
  final UserRepository _userRepository;
  ContactUs({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  static const String routeName = '/material/text-form-field';

  @override
  ContactUsState createState() => ContactUsState();
}

class PersonData {
  String name = '';
  String phoneNumber = '';
  String email = '';
  String password = '';
  String message = '';
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
  });

  final Key fieldKey;
  final String hintText;
  final String labelText;
  final String helperText;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      obscureText: _obscureText,
      maxLength: 8,
      onSaved: widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        filled: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscureText ? 'show password' : 'hide password',
          ),
        ),
      ),
    );
  }
}

class ContactUsState extends State<ContactUs> {
  UserRepository get _userRepository => widget._userRepository;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PersonData person = PersonData();

  void _showInSnackBar(String value, {IconData icon: Icons.error, color: Colors.red}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(value), Icon(icon)],
      ),
      backgroundColor: color,
    ));
  }

  bool _autovalidate = false;
  bool _formWasEdited = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey = GlobalKey<FormFieldState<String>>();

  Future<void> mailerSend(var message, var smtpServer) async {
    try {
      final sendReport = await send(message, smtpServer);
      _showInSnackBar('Message is sent for ${person.email}', color: Colors.blue, icon: Icons.info);

      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.${e.message} and ${e.problems.length}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
//          _scaffoldKey.currentState.showSnackBar(SnackBar(
//            content: Text('Problem: ${p.code}: ${p.msg}'),
//          ));
      }
    }
  }

//  void _handleSubmitted() {
//    final FormState form = _formKey.currentState;
//    if (!form.validate()) {
//      _autovalidate = true; // Start validating on every change.
//      _showInSnackBar('Please fix the errors in red before submitting.');
//    } else {
//      form.save();
//      mailerSend(message, smtpServer);
//      _showInSnackBar('Message is sent for ${person.email}', color: Colors.blue, icon: Icons.info);
//    }
//  }

  String _validateName(String value) {
    _formWasEdited = true;
    if (value.isEmpty)
      return 'Name is required.';
    final RegExp nameExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only alphabetical characters.';
    return null;
  }

  String _validateEmail(String value) {
    _formWasEdited = true;
    if (value.isEmpty)
      return 'Email is required.';
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    if (!emailRegExp.hasMatch(value))
      return 'Please enter valid email address.';
    return null;
  }

  String _validatePhoneNumber(String value) {
    _formWasEdited = true;
    final RegExp phoneExp = RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$');
    if (!phoneExp.hasMatch(value))
      return '(###) ###-#### - Enter a US phone number.';
    return null;
  }

  String _validatePassword(String value) {
    _formWasEdited = true;
    final FormFieldState<String> passwordField = _passwordFieldKey.currentState;
    if (passwordField.value == null || passwordField.value.isEmpty)
      return 'Please enter a password.';
    if (passwordField.value != value)
      return 'The passwords don\'t match';
    return null;
  }

  Future<bool> _warnUserAboutInvalidData() async {
    final FormState form = _formKey.currentState;
    if (form == null || !_formWasEdited || form.validate())
      return true;

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('This form has errors'),
          content: const Text('Really leave this form?'),
          actions: <Widget> [
            FlatButton(
              child: const Text('YES'),
              onPressed: () { Navigator.of(context).pop(true); },
            ),
            FlatButton(
              child: const Text('NO'),
              onPressed: () { Navigator.of(context).pop(false); },
            ),
          ],
        );
      },
    ) ?? false;
  }

  String username = 'superior.tech.au@hotmail.com';
  String password = 'Intelligentreceipt1';

  @override
  Widget build(BuildContext context) {

    final smtpServer = hotmail(username, password);

    void _handleSubmitted() {
      final FormState form = _formKey.currentState;
      if (!form.validate()) {
        _autovalidate = true; // Start validating on every change.
        _showInSnackBar('Please fix the errors in red before submitting.');
      } else {
        form.save();

        final message = Message()
          ..from = Address(username, 'Your name')
          ..recipients.add('support@superiortech.com.au')
          ..ccRecipients.addAll(['bruce.song.au@gmail.com ', 'rong.lin3000@gmail.com'])
//      ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
//      ..bccRecipients.add(Address('bccAddress@example.com'))
          ..subject = '${person.name} Feedback'
          ..text = '${person.message} from ${person.email}';
//      ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";
        
        mailerSend(message, smtpServer);
      }
    }

    return Scaffold(
      drawerDragStartBehavior: DragStartBehavior.down,
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          autovalidate: _autovalidate,
          onWillPop: _warnUserAboutInvalidData,
          child: Scrollbar(
            child: SingleChildScrollView(
              dragStartBehavior: DragStartBehavior.down,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 24.0),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.person),
                      hintText: 'What do people call you?',
                      labelText: 'Name',
                    ),
                    onSaved: (String value) { person.name = value; },
//                    validator: _validateName,
                  ),
                  const SizedBox(height: 24.0),
//                  TextFormField(
//                    decoration: const InputDecoration(
//                      border: UnderlineInputBorder(),
//                      filled: true,
//                      icon: Icon(Icons.phone),
//                      hintText: 'Where can we reach you?',
//                      labelText: 'Phone Number *',
//                      prefixText: '+1',
//                    ),
//                    keyboardType: TextInputType.phone,
//                    onSaved: (String value) { person.phoneNumber = value; },
//                    validator: _validatePhoneNumber,
//                    // TextInputFormatters are applied in sequence.
//                    inputFormatters: <TextInputFormatter> [
//                      WhitelistingTextInputFormatter.digitsOnly,
//                      // Fit the validating format.
//                      _phoneNumberFormatter,
//                    ],
//                  ),
//                  const SizedBox(height: 24.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.email),
                      hintText: 'Your email address',
                      labelText: 'Email *',
                    ),
                    initialValue: _userRepository.currentUser.email,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String value) { person.email = value; },
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Tell us about your thoughts on our product.',
                      helperText: 'Tell us about what help that you need.',
                      labelText: 'Message',
                    ),
                    maxLines: 5,
                    onSaved: (String value) { person.message = value; },
                  ),
//                  const SizedBox(height: 24.0),
//                  TextFormField(
//                    keyboardType: TextInputType.number,
//                    decoration: const InputDecoration(
//                      border: OutlineInputBorder(),
//                      labelText: 'Salary',
//                      prefixText: '\$',
//                      suffixText: 'USD',
//                      suffixStyle: TextStyle(color: Colors.green),
//                    ),
//                    maxLines: 1,
//                  ),
//                  const SizedBox(height: 24.0),
//                  PasswordField(
//                    fieldKey: _passwordFieldKey,
//                    helperText: 'No more than 8 characters.',
//                    labelText: 'Password *',
//                    onFieldSubmitted: (String value) {
//                      setState(() {
//                        person.password = value;
//                      });
//                    },
//                  ),
//                  const SizedBox(height: 24.0),
//                  TextFormField(
//                    enabled: person.password != null && person.password.isNotEmpty,
//                    decoration: const InputDecoration(
//                      border: UnderlineInputBorder(),
//                      filled: true,
//                      labelText: 'Re-type password',
//                    ),
//                    maxLength: 8,
//                    obscureText: true,
//                    validator: _validatePassword,
//                  ),
                  const SizedBox(height: 24.0),
                  Center(
                    child: RaisedButton(
                      child: const Text('SUBMIT'),
                      onPressed: _handleSubmitted,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    '* indicates required field',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}