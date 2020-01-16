import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:upgrader/upgrader.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

class CheckUpdateScreen extends StatefulWidget {
  @override
  _CheckUpdateScreenState createState() => _CheckUpdateScreenState();
}

class _CheckUpdateScreenState extends State<CheckUpdateScreen> {
  AppUpdateInfo _updateInfo;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  bool _flexibleUpdateAvailable = false;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) => _showError(e));
  }

  Future<AppUpdateInfo> initialize() async {
    return _updateInfo = await InAppUpdate.checkForUpdate();
  }

  void _showError(dynamic exception) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(exception.toString())));
  }

  bool _isUpdateAvailable() {
    return true;
    return (_updateInfo != null) ? _updateInfo.updateAvailable : false;
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
        title: Text(allTranslations.text("app.settings-page.in-app-update-title")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
                future: Upgrader().initialize(),
                builder: (BuildContext context, AsyncSnapshot<bool> processed) {
                  if (processed.connectionState == ConnectionState.done) {
                    return Column(
                      children: <Widget>[
                        Center(
                          child: Text(
    allTranslations.text("app.settings-page.current-version-label") + '${Upgrader().currentInstalledVersion()}'),
                        ),
//                        Center(
//                          child: Text(
//                              'current AppStore version ${Upgrader().currentAppStoreVersion()}'),
//                        ),
                      ],
                    );
                  }
                  return Container(width: 0.0, height: 0.0);
                }),
            FutureBuilder(
                future: initialize(),
                builder: (BuildContext context, AsyncSnapshot<AppUpdateInfo> processed) {
                  if (processed.connectionState == ConnectionState.done) {
                    return  Center (child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: _isUpdateAvailable() ? Text(allTranslations.text("app.settings-page.new-version-available")): Text(allTranslations.text("app.settings-page.already-updated-label")),
                        ),
                        Container ( height: 30,),
                        _isUpdateAvailable() ? ButtonTheme (
                          minWidth: 200.0,
                          height: 40.0,
                          child: RaisedButton(
                            child: Text(allTranslations.text("app.settings-page.immediate-update-label")),
                            onPressed: _isUpdateAvailable() ? () {
                              InAppUpdate.performImmediateUpdate().catchError((e) => _showError(e));
                            } : null,
                          ),
                        ) : Container(),
                        _isUpdateAvailable() ? ButtonTheme (
                          minWidth: 200.0,
                          height: 40.0,
                          child: RaisedButton(
                            child: Text(allTranslations.text("app.settings-page.flexible-update-label")),
                            onPressed: _isUpdateAvailable() ? () {
                              InAppUpdate.startFlexibleUpdate().then((_) {
                                setState(() {
                                  _flexibleUpdateAvailable = true;
                                });
                              }).catchError((e) => _showError(e));
                            } : null,
                          ),
                        ) : Container(),
                        _isUpdateAvailable() && _flexibleUpdateAvailable ? ButtonTheme (
                          minWidth: 200.0,
                          height: 40.0,
                          child: RaisedButton(
                            child: Text(allTranslations.text("app.settings-page.complete-flexible-update-label")),
                            onPressed: !_flexibleUpdateAvailable ? null : () {
                              InAppUpdate.completeFlexibleUpdate().then((_) {
                                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Success!')));
                              }).catchError((e) => _showError(e));
                            },
                          ),
                        ) : Container(),
                      ],
                    ));
                  }
                  return Container(width: 0.0, height: 0.0);
                }),

//            RaisedButton(
//              child: Text('Check for Update'),
//              onPressed: () => checkForUpdate(),
//            ),

          ],
        ),
      ),
    );
  }
}
