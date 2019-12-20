import 'package:flutter/material.dart';

void showUnsupportedVersionAlert(BuildContext context) {
  // set up the buttons
  Widget upgradeButton = FlatButton(
    child: Text("Upgrade Now ..."),
    onPressed:  () {},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Version not supported"),
    content: Text("Your version of IR is not being supported, please upgrade now."),
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