import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/main_screen/functions_page/tax_return_subpage.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'function_card.dart';
import 'package:intelligent_receipt/receipt/archived_receipts_page/archived_receipts_page.dart';

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
      body: OrientationBuilder(builder: (context, orientation) {
        return
        Column(
        children: <Widget>[
          FunctionCard(ArchivedReceiptsPage(userRepository: _userRepository),
              allTranslations.text('app.functions-page.archived-receipts-title'),
              allTranslations.text('app.functions-page.archived-receipts-description')),
          Flexible(
            fit: FlexFit.tight,
            child: Wrap(
              children: <Widget>[
                FractionallySizedBox(
                  widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                  child: Container(
                    height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.2: 0.4),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ArchivedReceiptsPage(userRepository: _userRepository))
                        );
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(allTranslations.text('app.functions-page.archived-receipts-title')),
                          subtitle: Text(allTranslations.text('app.functions-page.archived-receipts-description')),
                        ),
                      ),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                  child: Container(
                    height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.2: 0.4),
                    child:GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return TaxReturnSubpage(userRepository: _userRepository);
                          }),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(allTranslations.text('Tax Return')),
                          subtitle: Text(allTranslations.text('Tax Returnv')),
//                          subtitle: Icon(Icons.collections_bookmark, size: MediaQuery.of(context).size.height * 0.1,),
                        ),
                      ),
                    ),

                  ),
                ),
                FractionallySizedBox(
                  widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                  child: Container(
                    height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.2: 0.4),
                    child:GestureDetector(
                      onTap: () {
//                        widget.action(2);
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(allTranslations.text('tbd')),
                          subtitle: Text(allTranslations.text('tbd')),
//                          subtitle: Icon(Icons.collections_bookmark, size: MediaQuery.of(context).size.height * 0.1,),
                        ),
                      ),
                    ),

                  ),
                ),
                FractionallySizedBox(
                  widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                  child: Container(
                    height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.2: 0.4),
                    child:GestureDetector(
                      onTap: () {
//                        widget.action(2);
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(allTranslations.text('tbd')),
                          subtitle: Text(allTranslations.text('tbd')),
//                          subtitle: Icon(Icons.collections_bookmark, size: MediaQuery.of(context).size.height * 0.1,),
                        ),
                      ),
                    ),

                  ),
                ),
              ],
            ),
          ),

        ],
      );}),
    );

  }
}
