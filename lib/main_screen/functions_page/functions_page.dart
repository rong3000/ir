import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/main_screen/functions_page/tax_return_card.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'function_card.dart';
import 'package:intelligent_receipt/receipt/archived_receipts_page/archived_receipts_page.dart';
import 'quarterlygroup_function_card.dart';

class FunctionsPage extends StatefulWidget {
  final UserRepository _userRepository;

  final String name;
  FunctionsPage(
      {Key key, @required UserRepository userRepository, @required this.name})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _FunctionsPageState createState() => _FunctionsPageState();
}

class _FunctionsPageState extends State<FunctionsPage> {
  UserRepository get _userRepository => widget._userRepository;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          TaxReturnCard(userRepository: _userRepository),
          QuarterlyGroupCard(_userRepository)
        ],
      ),
    );
  }
}
