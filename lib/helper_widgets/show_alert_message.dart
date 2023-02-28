import 'package:flutter/material.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

void showAlertMessage(BuildContext context, {@required String title, @required String message}) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: new Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text(allTranslations.text('words.close')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    });
}
