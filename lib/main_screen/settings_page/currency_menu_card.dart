import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/main_screen/settings_page/currency_screen/currency_screen.dart';
import 'package:intelligent_receipt/user_repository.dart';

class CurrencyMenuCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CurrencyMenuCardState();
  }
}

class _CurrencyMenuCardState extends State {
  UserRepository _userRepository;
  Future<DataResult> _getSettingsFuture;
  Future<DataResult> _getCurrenciesFuture;

  void getSettingsFromServer() {
    _getSettingsFuture =
        _userRepository.settingRepository.getSettingsFromServer();
  }

  void getCurrenciesFromServer() {
    _getCurrenciesFuture =
        _userRepository.settingRepository.getCurrenciesFromServer();
  }

  @override
  void initState() {
    _userRepository = RepositoryProvider.of<UserRepository>(context);
    getCurrenciesFromServer();
    getSettingsFromServer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
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
                      defaultCurrency: _userRepository.settingRepository
                          .getDefaultCurrency());
                }),
              ),
            },
            child: Row(
              // Replace with a Row for horizontal icon + text
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                FutureBuilder<DataResult>(
                  future: _getSettingsFuture,
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
                            future: _getCurrenciesFuture,
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
                                    return AutoSizeText(
                                      '${snapshot.error}',
                                      style: TextStyle(fontSize: 14),
                                      minFontSize: 1,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  } else {
                                    Currency defaultCurrency = _userRepository
                                        .settingRepository
                                        .getDefaultCurrency();
                                    return (defaultCurrency != null)
                                        ? Expanded(
                                            child: AutoSizeText(
                                              "${defaultCurrency.name} ${defaultCurrency.symbol}",
                                              style: TextStyle(fontSize: 14),
                                              minFontSize: 1,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        : AutoSizeText(
                                            '',
                                            style: TextStyle(fontSize: 10),
                                            minFontSize: 4,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                  }
                              }
                            },
                          );
                        }
                    }
                  },
                ),
                Icon(Icons.more_horiz),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
