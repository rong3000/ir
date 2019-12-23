import 'package:flutter/material.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

void showUnsupportedVersionAlert(BuildContext context) {
  // set up the buttons
  Widget upgradeButton = RaisedButton(
    color: Colors.blue,
    child: Text(allTranslations.text('app.unsupported-version.button')),
    onPressed:  () {},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(allTranslations.text('app.unsupported-version.title')),
    content: Text(allTranslations.text('app.unsupported-version.text')),
    actions: [
      upgradeButton,
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class UnsupportedVersion extends StatelessWidget {
  UnsupportedVersion({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Container (
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column (
          children: <Widget>[
            Container (
              height: 32,
            ),
            Text(allTranslations.text('app.unsupported-version.text')),
            Container (
              height: 32,
            ),
            RaisedButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text(allTranslations.text('app.unsupported-version.button')),
              onPressed:  () {},
            )
          ],
        ),
      )
    );
  }
}