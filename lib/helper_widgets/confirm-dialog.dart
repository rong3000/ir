import 'package:flutter/material.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

class ConfirmDialog {
  
  static Widget Function(BuildContext) builder(context, { @required Widget title, @required Widget content}) {
    return (context) => AlertDialog(
          title: title, 
          content: content,
          actions: <Widget>[
            FlatButton(
              child: Text(allTranslations.text('words.ok')),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text(allTranslations.text('words.cancel')),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
  }
}
