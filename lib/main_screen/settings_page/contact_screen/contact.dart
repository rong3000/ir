// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
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
        title: Text(allTranslations.text('app.settings-page.contact-us-menu-item-title')),
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
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.person),
                      labelText: allTranslations.text('app.contact-screen.name'),
                    ),
                    onSaved: (String value) { person.name = value; },
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.email),
                      labelText: allTranslations.text('words.email') + '*',
                    ),
                    initialValue: _userRepository.currentUser.email,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String value) { person.email = value; },
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: allTranslations.text('words.message'),
                    ),
                    maxLines: 5,
                    onSaved: (String value) { person.message = value; },
                  ),
                  const SizedBox(height: 24.0),
                  Center(
                    child: RaisedButton(
                      child: Text(allTranslations.text('words.submit')),
                      onPressed: _handleSubmitted,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(allTranslations.text('app.contact-screen.form-indication'),
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