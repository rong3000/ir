import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/main_screen/settings_page/category_screen/category_screen.dart';
import 'package:intelligent_receipt/main_screen/settings_page/currency_screen/currency_screen.dart';

import '../../user_repository.dart';

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
//    getDataResultFromServer();
    if (_userRepository.receiptRepository.receipts.isNotEmpty) {
      return Scaffold(
        body: Column(
          children: <Widget>[
//            Text("${_userRepository.receiptRepository.receipts[1].companyName}"),
//            Text("${dataResult.success}"),
            Card(
              child: ListTile(
                leading: Icon(Icons.album),
                title: AutoSizeText(
                  '${widget.name}\'s Receipts',
                  style: TextStyle(fontSize: 18),
                  minFontSize: 8,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: SizedBox(
                  width: 140,
                  child: FlatButton(
                    onPressed: () => {print('viewall')},
//                    color: Colors.orange,
//                    padding: EdgeInsets.all(10.0),
                    child: Row(
                        // Replace with a Row for horizontal icon + text
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text("View All"),
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
                                      _currency = _userRepository
                                          .settingRepository
                                          .getDefaultCurrency();
                                      return Row(
                                        children: <Widget>[
                                          Text("${_currency.name} "),
                                          Text("${_currency.symbol}"),
                                        ],
                                      );
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
          ],
        ),
      );
    } else {
      return Container();
    }
    //        if (dataResult.success) {
  }
}
