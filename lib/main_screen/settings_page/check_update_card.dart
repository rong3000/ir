import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/main_screen/settings_page/plan_screen/plan_screen.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

import 'check_update_screen/check_update_screen.dart';
import 'check_update_screen/check_update_screen_ios.dart';

class CheckUpdateCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return Platform.isIOS ? CheckUpdateScreenIos(
            ): CheckUpdateScreenIos(
            );
          }),
        )
      },
      child: Card(
        child: ListTile(
          title: AutoSizeText(
            allTranslations.text('app.settings-page.check-update-menu-item-title'),
            style: TextStyle(fontSize: 18),
            minFontSize: 8,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

