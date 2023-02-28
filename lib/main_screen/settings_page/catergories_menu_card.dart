import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/main_screen/settings_page/category_screen/category_screen.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';

class CatergoryMenuCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CategoryMenuCardState();
  }
}

class _CategoryMenuCardState extends State {
  UserRepository _userRepository;
  Future<DataResult> _getCategoriesFuture;

  @override
  void initState() {
    _userRepository = RepositoryProvider.of<UserRepository>(context);
    getCategoriesFromServer();
    super.initState();
  }

  void getCategoriesFromServer({bool forceRefresh : false}) {
  _getCategoriesFuture = _userRepository.categoryRepository.getCategoriesFromServer(forceRefresh: forceRefresh);
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: AutoSizeText(
          allTranslations.text('app.settings-page.category-menu-item-title'),
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
                      defaultCurrency: _userRepository.settingRepository
                          .getDefaultCurrency());
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
                            return new Text(allTranslations.text('app.common.loading-status'));
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
    );
  }
}
