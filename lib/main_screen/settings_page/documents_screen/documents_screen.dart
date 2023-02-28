import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';

class DocumentsScreen extends StatefulWidget {

  DocumentsScreen({Key key})
      : super(key: key);

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  UserRepository _userRepository;

  @override
  void initState() {
    _userRepository = RepositoryProvider.of<UserRepository>(context);
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
}
