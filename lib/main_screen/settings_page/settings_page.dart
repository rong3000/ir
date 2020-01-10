import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/main_screen/settings_page/catergories_menu_card.dart';
import 'package:intelligent_receipt/main_screen/settings_page/contact_menu_card.dart';
import 'package:intelligent_receipt/main_screen/settings_page/currency_menu_card.dart';
import 'package:intelligent_receipt/main_screen/settings_page/document_knowledge_menu_card.dart';
import 'package:intelligent_receipt/main_screen/settings_page/invite_friend_menu_card.dart';
import 'package:intelligent_receipt/main_screen/settings_page/plan-information_menu_card.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences_menu_card.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';

import 'check_update_card.dart';


class SettingsPage extends StatefulWidget {
  final UserRepository _userRepository;

  final String name;
  SettingsPage(
      {Key key, @required UserRepository userRepository, @required this.name})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: ListView(
          children: <Widget>[
            Card(
              child: ListTile(
                leading: Icon(Icons.album),
                title: AutoSizeText(
                  allTranslations.text('app.settings-page.title'),
                  style: TextStyle(fontSize: 18),
                  minFontSize: 8,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            PreferencesMenuCard(),
            CurrencyMenuCard(),
            CatergoryMenuCard(),
            CheckUpdateCard(),
            PlanMenuCard(),
            //DocumentKnowledgeMenuCard(),
            //InviteFriendMenuCard(),
            ContactMenuCard(),
          ],
        ),
      );
  }
}
