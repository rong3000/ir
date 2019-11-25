import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/main_screen/settings_page/category_screen/category_screen.dart';
import 'package:intelligent_receipt/main_screen/settings_page/contact_screen/contact.dart';
import 'package:intelligent_receipt/main_screen/settings_page/currency_screen/currency_screen.dart';
import 'package:intelligent_receipt/main_screen/settings_page/documents_screen/documents_screen.dart';
import 'package:intelligent_receipt/main_screen/settings_page/invite_screen/invite_screen.dart';
import 'package:intelligent_receipt/main_screen/settings_page/plan_screen/plan_screen.dart';
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
  Currency _currency;

  Future<void> getDataResultFromServer() async {
    dataResult = await _userRepository.receiptRepository
        .getReceiptsFromServer(forceRefresh: true);
    setState(() {});
  }

  Future<void> getSettingFromServer() async {
    DataResult result =
        await _userRepository.settingRepository.getSettingsFromServer();
  }

  @override
  void initState() {
//    getDataResultFromServer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          children: <Widget>[
//            Text("${_userRepository.receiptRepository.receipts[1].companyName}"),
//            Text("${dataResult.success}"),
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
//                trailing: SizedBox(
//                  width: 140,
//                  child: FlatButton(
//                    onPressed: () {
//                      Navigator.push(
//                        context,
//                        MaterialPageRoute(builder: (context) => ReceiptsPage(userRepository: _userRepository)),
//                      );
//                    },
////                    color: Colors.orange,
////                    padding: EdgeInsets.all(10.0),
//                    child: Row(
//                        // Replace with a Row for horizontal icon + text
//                        mainAxisAlignment: MainAxisAlignment.end,
//                        mainAxisSize: MainAxisSize.max,
//                        children: <Widget>[
//                          Text("View All"),
//                          Icon(Icons.more_horiz),
//                        ]),
//                  ),
//                ),
              ),
            ),
            Card(
              child: ListTile(
//                leading: Icon(Icons.album),
                title: AutoSizeText(
                  'Default Currency',
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
                          return CurrencyScreen(
                              userRepository: _userRepository,
                              title: 'Choose Currency',
                              defaultCurrency: _currency);
                        }),
                      )
                    },
//                    color: Colors.orange,
//                    padding: EdgeInsets.all(10.0),
                    child: Row(
                        // Replace with a Row for horizontal icon + text
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          FutureBuilder<DataResult>(
                              future: _userRepository.settingRepository
                                  .getSettingsFromServer(),
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
                                      return FutureBuilder<DataResult>(
                                          future: _userRepository.settingRepository
                                              .getCurrenciesFromServer(),
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
                                                if (snapshot.hasError) {
                                                  return
//                                                    new Text(
//                                                    '${snapshot.error}',
//                                                    style: TextStyle(color: Colors.red),
//                                                  );
                                                  AutoSizeText(
                                                    '${snapshot.error}',
                                                    style: TextStyle(fontSize: 14),
                                                    minFontSize: 1,
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  );
                                                } else {
                                                  _currency = _userRepository
                                                      .settingRepository
                                                      .getDefaultCurrency();
                                                  return (_currency != null) ? Expanded(
                                                    child: AutoSizeText(
                                                      "${_currency.name} ${_currency.symbol}",
                                                      style: TextStyle(fontSize: 14),
                                                      minFontSize: 1,
                                                      maxLines: 3,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
//                                        children: <Widget>[//
////                                          Text("${_currency.name} "),
////                                          Text("${_currency.symbol}"),
//                                        ],
                                                  ) : AutoSizeText(
                                                    '',
                                                    style: TextStyle(fontSize: 10),
                                                    minFontSize: 4,
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  );
                                                }

                                            }
                                          });
                                    }
                                }
                              }),
                          Icon(Icons.more_horiz),
                        ]),
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
//                leading: Icon(Icons.album),
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
                              defaultCurrency: _currency);
                        }),
                      )
                    },
//                    color: Colors.orange,
//                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      // Replace with a Row for horizontal icon + text
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          FutureBuilder<DataResult>(
                              future: _userRepository.categoryRepository.getCategoriesFromServer(),
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
//                          Text("AUD A\$"),
//                          Icon(Icons.more_horiz),
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
//                leading: Icon(Icons.album),
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
//                leading: Icon(Icons.album),
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
//                leading: Icon(Icons.album),
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
//                              userRepository: _userRepository,
//                              title: 'Contact Us',
//                              defaultCurrency: _currency
                    );
                  }),
                )
              },
              child: Card(
                child: ListTile(
//                leading: Icon(Icons.album),
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
