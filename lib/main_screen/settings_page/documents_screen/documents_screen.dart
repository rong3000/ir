import 'package:flutter/material.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';

class DocumentsScreen extends StatefulWidget {
  final UserRepository _userRepository;

  DocumentsScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  UserRepository get _userRepository => widget._userRepository;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('app.document-screen.title')),
      ),
      body: OrientationBuilder(builder: (context, orientation) {
        return Center(
          child: Column(
            children: <Widget>[
              Flexible(
                fit: FlexFit.tight,
                child: Wrap(
                  children: <Widget>[
                    FractionallySizedBox(
                      widthFactor:
                      orientation == Orientation.portrait ? 0.8 : 0.3,
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            (orientation == Orientation.portrait ? 0.2 : 0.4),
                        child: GestureDetector(
                          onTap: () {
                            print('1');
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(allTranslations.text('app.document-screen.snap-receipt-process-label')),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor:
                      orientation == Orientation.portrait ? 0.8 : 0.3,
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            (orientation == Orientation.portrait ? 0.2 : 0.4),
                        child: GestureDetector(
                          onTap: () {
                            print('2');
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(allTranslations.text('app.document-screen.archived-group-features-label')
                                 ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor:
                      orientation == Orientation.portrait ? 0.8 : 0.3,
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            (orientation == Orientation.portrait ? 0.2 : 0.4),
                        child: GestureDetector(
                          onTap: () {
                            print('3');
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(allTranslations.text('app.document-screen.receipt-group-information')
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _ackAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Not in stock'),
          content: const Text('This item is no longer available'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
