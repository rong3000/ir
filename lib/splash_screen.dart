import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Upgrader().clearSavedSettings();

    // On Android, setup the Appcast.
    // On iOS, the default behavior will be to use the App Store version of
    // the app, so update the Bundle Identifier in example/ios/Runner with a
    // valid identifier already in the App Store.
    final String appcastURL =
        'https://raw.githubusercontent.com/larryaasen/upgrader/master/test/testappcast.xml';
    final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ["android"]);

    return Scaffold(
      body: UpgradeAlert(
        appcastConfig: cfg,
        debugLogging: true,
        child: Center(child:
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Image.asset('assets/ir_logo.png', height: 200),
        ),),
      )
    );
  }
}
