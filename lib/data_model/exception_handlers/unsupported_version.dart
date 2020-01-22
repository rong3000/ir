import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:upgrader/upgrader.dart';

void showUpgradeResult(BuildContext context, String message) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(allTranslations.text('app.unsupported-version.upgrade-result')),
        content: Text(allTranslations.text(message)),
        actions: <Widget>[
          FlatButton(
            child: Text(allTranslations.text('words.close')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

Future<void> onUpgradeButtonPressed(BuildContext context) async {
  if (Platform.isAndroid || Platform.isIOS) {
    Upgrader().clearSavedSettings();
    final String appcastURL =
        'https://firebasestorage.googleapis.com/v0/b/intelligent-receipt.appspot.com/o/irappcast.xml?alt=media';
    final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ["android", "ios"]);
    Upgrader().appcastConfig = cfg;
    Upgrader().initialize().then((_) {
      Upgrader().onUserUpdated(context, true);
    });
  } else {
    showUpgradeResult(context, allTranslations.text('app.unsupported-version.unsupported-platform'));
  }
}

void showUnsupportedVersionAlert(BuildContext context) {
  // set up the buttons
  Widget upgradeButton = RaisedButton(
    color: Colors.blue,
    child: Text(allTranslations.text('app.unsupported-version.button')),
    onPressed:  () {
      onUpgradeButtonPressed(context);
    },
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

class InformationScreen extends StatelessWidget {
  InformationScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Center(
        child: Container (
          color: Colors.white,
          child: Column (
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container (
                height: 32,
              ),
              Text(allTranslations.text('app.unsupported-version.opening-app-store'), style: new TextStyle(
                  fontSize: 18, color: Colors.black, decoration: null)),
              Container (
                height: 32,
              ),
            ],
          ),
        )
    );
  }
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
                onPressed:  () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return InformationScreen();
                    }),
                  );
                  onUpgradeButtonPressed(context);
                },
              )
            ],
          ),
        )
    );
  }
}