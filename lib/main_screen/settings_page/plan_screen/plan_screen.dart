import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intelligent_receipt/receipt/upload_receipt_image/upload_receipt_image.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/data_model/enums.dart';

import 'credit_card_page.dart';

class PlanScreen extends StatefulWidget {
  final UserRepository _userRepository;

  PlanScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
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
        title: Text('Plan Information'),
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
                                  'Your current plan is Free Trial, now you have only 3 snaps and 1 free group left.'),
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
                            title: Text('Basic Plan'),
                            subtitle: Text(
                                'With our basic plan, you can snap maximum 10 receipts per month and generate 2 groups.'),
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
                              child: Text('Upgrade Now'),
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
                            title: Text('Premium Plan'),
                            subtitle: Text(
                                'You will get unlimited snaps and groups.'),
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
                              child: Text('Upgrade Now'),
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
