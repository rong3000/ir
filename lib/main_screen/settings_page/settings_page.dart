import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/main_screen/settings_page/category_screen/category_screen.dart';
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
        super(key: key) {}

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserRepository get _userRepository => widget._userRepository;
  DataResult dataResult;
  Future<DataResult> _getCategoriesFuture = null;

  void getCategoriesFromServer({bool forceRefresh : false}) {
    _getCategoriesFuture = _userRepository.categoryRepository.getCategoriesFromServer(forceRefresh: forceRefresh);
  }

  @override
  void initState() {
    getCategoriesFromServer();
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
            CurrencyMenuCard(),//currency
            Card(
              child: ListTile(
                title: AutoSizeText(
                  'Categories',
                  style: TextStyle(fontSize: 18),
                  minFontSize: 8,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: SizedBox(
                  width: 140,
                  child: FlatButton(
                    onPressed: () => {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return CategoryScreen(
                              userRepository: _userRepository,
                              title: 'Edit Categories',
                              defaultCurrency: _userRepository.settingRepository.getDefaultCurrency());
                        }),
                      )
                    },
                    child: Row(
                      // Replace with a Row for horizontal icon + text
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          FutureBuilder<DataResult>(
                              future: _getCategoriesFuture,
                              builder: (BuildContext context,
                                  AsyncSnapshot<DataResult> snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.none:
                                    return new Text('Loading...');
                                  case ConnectionState.waiting:
                                    return new Center(
                                        child: new CircularProgressIndicator());
                                  case ConnectionState.active:
                                    return new Text('');
                                  case ConnectionState.done:
                                    {
                                      return Icon(Icons.more_horiz);
                                    }
                                }
                              }),
                        ]),
                  ),
                ),
              ),
            ),
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
