import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/preferences_screen.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

class PreferencesMenuCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String menuTitle =
        allTranslations.text('app.settings-page.preferences-menu-item-title');

    return Card(
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return PreferencesScreen();
            })
          );
        },
        child: ListTile(
          title: AutoSizeText(
            menuTitle,
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
