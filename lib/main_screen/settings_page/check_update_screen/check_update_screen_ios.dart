import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

class CheckUpdateScreenIos extends StatefulWidget {
  @override
  _CheckUpdateScreenIosState createState() => _CheckUpdateScreenIosState();
}

class _CheckUpdateScreenIosState extends State<CheckUpdateScreenIos> {
//  AppUpdateInfo _updateInfo;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  bool _flexibleUpdateAvailable = false;

  @override
  void initState() {
    super.initState();
  }

  void _showError(dynamic exception) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(exception.toString())));
  }

  @override
  Widget build(BuildContext context) {
    Upgrader().clearSavedSettings();
    final String appcastURL =
        'https://firebasestorage.googleapis.com/v0/b/intelligent-receipt.appspot.com/o/irappcast.xml?alt=media';
    final cfg =
        AppcastConfiguration(url: appcastURL, supportedOS: ["android", "ios"]);
    Upgrader().appcastConfig = cfg;
    Upgrader().debugLogging = true;

    if (Upgrader().debugLogging) {
      print('UpgradeCard: build UpgradeCard');
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title:
            Text(allTranslations.text('app.settings-page.in-app-update-title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
            future: Upgrader().initialize(),
            builder: (BuildContext context, AsyncSnapshot<bool> processed) {
              if (processed.connectionState == ConnectionState.done) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(allTranslations
                              .text('app.settings-page.current-version-label') +
                          '${Upgrader().currentInstalledVersion()}'),
                    ),
                    Center(
                        child: Upgrader().currentAppStoreVersion() == null
                            ? (Platform.isIOS ? Text(allTranslations.text('app.settings-page.appStore-version-unavailable')): Text(allTranslations.text('app.settings-page.playStore-version-unavailable')))
                            : (Platform.isIOS ? Text(allTranslations.text('app.settings-page.current-appstore-version-label') + '${Upgrader().currentAppStoreVersion()}')
                               : Text(allTranslations.text('app.settings-page.current-playstore-version-label') + '${Upgrader().currentAppStoreVersion()}'))
                    ),
                    Container(height: 20,),
                    Upgrader().isUpdateAvailable() ? ButtonTheme (
                      minWidth: 200.0,
                      height: 40.0,
                      child: RaisedButton(
                        child: Text(allTranslations.text("app.settings-page.immediate-update-label")),
                        onPressed: Upgrader().isUpdateAvailable() ? () {
                          Upgrader().onUserUpdated(context, true);
                        } : null,
                      ),
                    ) : Text(allTranslations.text("app.settings-page.already-updated-label")),
                    Container(height: 40,)
                  ],
                );
              }
              return Container(width: 0.0, height: 0.0);
            }),
      ),
    );
  }
}
