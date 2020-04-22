import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';

import '../../data_model/enums.dart';
import '../tax_return_page/tax_return_page.dart';

class TaxReturnSubpage extends StatefulWidget {
  final UserRepository _userRepository;
  final String name;
//  SearchBar({Key key, @required this.name, @required this.verified}) : super(key: key);

  TaxReturnSubpage({Key key, @required UserRepository userRepository, this.name})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _TaxReturnSubpageState createState() => _TaxReturnSubpageState();
}

class _TaxReturnSubpageState extends State<TaxReturnSubpage> {
  UserRepository get _userRepository => widget._userRepository;
  final TextEditingController _controller = new TextEditingController();

  String get name => widget.name;

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  Future<void> sendVerification() async {
    try {
      await _userRepository.currentUser.sendEmailVerification();
    } catch (e) {
      print(allTranslations.text('app.email-veri-screen.veri-email-sent-error'));
      print(e.message);
    }
  }

  void _showMessage(String title, String message) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: new Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text(allTranslations.text('app.email-veri-screen.close')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('Tax Return')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Column(children: <Widget>[
                ListTile(
                  title: Text(allTranslations.text('Tax Return 2019-2020')),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return TaxReturnPage(userRepository: _userRepository, fiscYear: FiscYear.Current);
                      }),
                    );
                  },
                ),
                ListTile(
                  title: Text(allTranslations.text('Tax Return 2018-2019')),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return TaxReturnPage(userRepository: _userRepository, fiscYear: FiscYear.Previous);
                      }),
                    );
                  },
                ),
              ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
