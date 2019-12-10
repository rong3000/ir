import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';

import 'credit_card_page.dart';

class PlanScreen extends StatefulWidget {

  PlanScreen({Key key}) : super(key: key);

  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
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
        title: Text(allTranslations.text('app.plan-screen.title')),
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
                              title: Text(
                                  'Your current plan is Free Trial, now you have only 3 snaps and 1 free group left.'),//TODO: addtrantaslation here when this is working
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
                            (orientation == Orientation.portrait ? 0.3 : 0.4),
                        child: Card(
                          child: ListTile(
                            title: Text(allTranslations.text('app.plan-screen.basic-plan-label')),
                            subtitle: Text(allTranslations.text('app.plan-screen.basic-plan-label-subtitle')),
                            trailing: RaisedButton(
                              onPressed: () => {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return CreditCardPage(
//                                      userRepository: _userRepository,
                                    );
                                  }),
                                )
                              },
                              child: Text(allTranslations.text('app.plan-screen.upgrade-now-label')),
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
                            (orientation == Orientation.portrait ? 0.3 : 0.4),
                        child: Card(
                          child: ListTile(
                            title: Text(allTranslations.text('app.plan-screen.premium-plan-label')),
                            subtitle: Text(allTranslations.text('app.plan-screen.premium-plan-label-subtitle')),
                            trailing: RaisedButton(
                              onPressed: () => {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return CreditCardPage(
//                                      userRepository: _userRepository,
                                    );
                                  }),
                                )
                              },
                              child: Text(allTranslations.text('app.plan-screen.upgrade-now-label')),
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
