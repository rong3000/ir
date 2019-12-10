import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/main_screen/settings_page/catergories_menu_card.dart';
import 'package:intelligent_receipt/main_screen/settings_page/contact_screen/contact.dart';
import 'package:intelligent_receipt/main_screen/settings_page/currency_menu_card.dart';
import 'package:intelligent_receipt/main_screen/settings_page/documents_screen/documents_screen.dart';
import 'package:intelligent_receipt/main_screen/settings_page/invite_screen/invite_screen.dart';
import 'package:intelligent_receipt/main_screen/settings_page/plan_screen/plan_screen.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences_menu_card.dart';
import 'package:intelligent_receipt/user_repository.dart';


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
  UserRepository get _userRepository => widget._userRepository;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          children: <Widget>[
            Card(
              child: ListTile(
                leading: Icon(Icons.album),
                title: AutoSizeText(
                  '${widget.name}\'s Setting',
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
            GestureDetector(
              onTap: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return PlanScreen(
                      userRepository: _userRepository,
                    );
                  }),
                )
              },
              child: Card(
                child: ListTile(
                  title: AutoSizeText(
                    'Plan Information',
                    style: TextStyle(fontSize: 18),
                    minFontSize: 8,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return DocumentsScreen(
                      userRepository: _userRepository,
                    );
                  }),
                )
              },
              child: Card(
                child: ListTile(
                  title: AutoSizeText(
                    'Documents & Knowledge Centre',
                    style: TextStyle(fontSize: 18),
                    minFontSize: 8,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return InviteScreen(
                    );
                  }),
                )
              },
              child: Card(
                child: ListTile(
                  title: AutoSizeText(
                    'Invite a friend',
                    style: TextStyle(fontSize: 18),
                    minFontSize: 8,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return TextFormFieldDemo(
                    );
                  }),
                )
              },
              child: Card(
                child: ListTile(
                  title: AutoSizeText(
                    'Contact Us',
                    style: TextStyle(fontSize: 18),
                    minFontSize: 8,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}
