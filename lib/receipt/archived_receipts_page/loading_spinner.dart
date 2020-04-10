import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ArchiveLoadingSpinner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            CircularProgressIndicator(),
          ],
        )
      ],
    );
  }
}
