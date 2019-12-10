import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intelligent_receipt/main_screen/settings_page/invite_screen/invite_screen.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

class InviteFriendMenuCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return InviteScreen();
          }),
        )
      },
      child: Card(
        child: ListTile(
          title: AutoSizeText(
            allTranslations.text('app.settings-page.invite-friend-menu-item-title'),
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
