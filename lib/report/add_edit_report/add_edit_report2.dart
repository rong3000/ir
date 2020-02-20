// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:intelligent_receipt/user_repository.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';


class AddEditReport2 extends StatefulWidget {
  final String title;
  final UserRepository _userRepository;
  final int _reportId;
  AddEditReport2(
      {Key key,
        @required UserRepository userRepository,
        this.title,
        int reportId : 0})
      : assert(userRepository != null),
        _userRepository = userRepository,
        _reportId = reportId,
        super(key: key);

  static const String routeName = '/material/text-form-field';

  @override
  AddEditReport2State createState() => AddEditReport2State();
}

class PersonData {
  String name = '';
  String phoneNumber = '';
  String email = '';
  String password = '';
  String message = '';
}

class AddEditReport2State extends State<AddEditReport2> {
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
  bool _formSubmitting = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey = GlobalKey<FormFieldState<String>>();

  Future<void> mailerSend(var message, var smtpServer) async {
    setState(() {
      _formSubmitting = true;
    });
    try {
      _showInSnackBar(allTranslations.text('app.contact-screen.sumbmitting'), color: Colors.blue, icon: Icons.info);
      final sendReport = await send(message, smtpServer);
      _showInSnackBar(allTranslations.text('app.contact-screen.success-line1') + '${person.name}\n' + allTranslations.text('app.contact-screen.success-line2'),
          color: Colors.blue, icon: Icons.info);
    } on MailerException catch (e) {
      for (var p in e.problems) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(allTranslations.text('app.contact-screen.fail-line1') + '\n' + allTranslations.text('app.contact-screen.fail-line2') + '${p.code}: ${p.msg}'),
          ));
      }
    }
    setState(() {
      _formSubmitting = false;
    });
  }

  String _validateGroupName(String value) {
    _formWasEdited = true;
    if (value.isEmpty)
      return allTranslations.text('app.contact-screen.email-required');
//    final RegExp emailRegExp = RegExp(
//      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
//    );
//    if (!emailRegExp.hasMatch(value))
//      return allTranslations.text('app.contact-screen.valid-email-required');
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
          title: Text(allTranslations.text('app.contact-screen.form-error')),
          content: Text(allTranslations.text('app.contact-screen.form-leaving')),
          actions: <Widget> [
            FlatButton(
              child: Text(allTranslations.text('words.ok')),
              onPressed: () { Navigator.of(context).pop(true); },
            ),
            FlatButton(
              child: Text(allTranslations.text('words.cancel')),
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
        _showInSnackBar(allTranslations.text('app.contact-screen.fix'));
      } else {
        form.save();

        final message = Message()
          ..from = Address(username, 'Superior Support')
          ..recipients.add('support@superiortech.com.au')
          ..bccRecipients.addAll(['bruce.song.au@gmail.com ', 'rong.lin3000@gmail.com'])
//      ..bccRecipients.add(Address('bccAddress@example.com'))
          ..subject = '${person.name}\'s Message'
          ..text = '${person.message} from ${person.email}';
//      ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";

        mailerSend(message, smtpServer);
      }
    }

    return Scaffold(
      drawerDragStartBehavior: DragStartBehavior.down,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
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
                      icon: Icon(Icons.title),
                      labelText: allTranslations.text('app.add-edit-report-page.group-name-label') + '*',
                    ),
                    onSaved: (String value) { person.name = value; },
                    validator: _validateGroupName,
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.description),
                      labelText: allTranslations.text('app.add-edit-report-page.description-label'),
                    ),
//                    initialValue: _userRepository.currentUser.email,
//                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String value) { person.email = value; },
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
                      child: Text(allTranslations.text('words.save')),
                      onPressed: _formSubmitting ? null : _handleSubmitted,
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