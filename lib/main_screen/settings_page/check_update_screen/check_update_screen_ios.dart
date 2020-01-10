import 'dart:async';

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

  // Platform messages are asynchronous, so we initialize in an async method.
//  Future<void> checkForUpdate() async {
//    InAppUpdate.checkForUpdate().then((info) {
//      setState(() {
//        _updateInfo = info;
//      });
//    }).catchError((e) => _showError(e));
//  }

  void _showError(dynamic exception) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(exception.toString())));
  }

  @override
  Widget build(BuildContext context) {
    Upgrader().clearSavedSettings();
    final String appcastURL =
        'https://raw.githubusercontent.com/larryaasen/upgrader/master/test/testappcast.xml';
    final cfg =
        AppcastConfiguration(url: appcastURL, supportedOS: ["android", "ios"]);
//    Upgrader().appcastConfig = cfg;
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
                  children: <Widget>[
                    Center(
                      child: Text(allTranslations
                              .text('app.settings-page.current-version-label') +
                          '${Upgrader().currentInstalledVersion()}'),
                    ),
                    Center(
                        child: Upgrader().currentAppStoreVersion() == null
                            ? Text(allTranslations.text(
                                'app.settings-page.appStore-version-unavailable'))
                            : Text(allTranslations.text(
                                    'app.settings-page.current-appstore-version-label') +
                                '${Upgrader().currentAppStoreVersion()}')),
//                    Center(
//                      child: Text(
//                          'currentAppStoreListingURL ${Upgrader().currentAppStoreListingURL()}'),
//                    ),
                    RaisedButton(
                      child: Text(allTranslations
                          .text('app.settings-page.immediate-update-label')),
                      onPressed: Upgrader().currentAppStoreListingURL() != null
                          ? () {
                              Upgrader().onUserUpdated(context, true);
                            }
                          : null,
                    ),
                  ],
                );
              }
              return Container(width: 0.0, height: 0.0);
            }),
      ),
    );
  }
}
