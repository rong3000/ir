import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return BlocListener(
        bloc: _homeBloc,
        listener: (BuildContext context, HomeState state) {
          if (state is State1) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('State1...'),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
          }
          if (state is State2) {
            _ackAlert(context);
          }
        },
        child: BlocBuilder(
            bloc: _homeBloc,
            builder: (BuildContext context, HomeState state) {
              return Scaffold(
                body: OrientationBuilder(builder: (context, orientation){
                  return
                    Column(
                      children: <Widget>[
                        Flexible(
                          fit: FlexFit.tight,
                          child: Wrap(
                            children: <Widget>[
                              FractionallySizedBox(
                                widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                                child: Container(
                                  height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.2: 0.4),
                                  child:
                                  Card(
                                    child: ListTile(
                                      title: Text('Add Your (First) Receipt'),
                                    ),
                                  ),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                                child: Container(
                                  height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.2: 0.4),
                                  child:
                                  Card(
                                    child: ListTile(
                                      title: Text('Manually Add Your (First) Receipt'),
                                    ),
                                  ),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                                child: Container(
                                  height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.2: 0.4),
                                  child:
                                  Card(
                                    child: ListTile(
                                      title: Text('View Imported Receipts'),
                                    ),
                                  ),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                                child: Container(
                                  height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.2: 0.4),
                                  child:
                                  Card(
                                    child: ListTile(
                                      title: Text('Add Your (First) Receipt'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                            fit: FlexFit.tight,
                            child: Wrap(
                              children: <Widget>[
                                FractionallySizedBox(
                                  widthFactor: orientation == Orientation.portrait ? 1: 0.33,
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.125: 0.32),
                                    child:
                                    Card(
                                      child: ListTile(
                                        leading: Icon(Icons.album),
                                        title: AutoSizeText(
                                          'Intelligent Receipt',
                                          style: TextStyle(fontSize: 18),
                                          minFontSize: 8,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: AutoSizeText(
                                          'Invite your friends to join IR then receive more free automatically scans',
                                          style: TextStyle(fontSize: 18),
                                          minFontSize: 8,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                      ),
                                    ),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: orientation == Orientation.portrait ? 1: 0.33,
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.125: 0.32),
                                    child:
                                    Card(
                                      child: ListTile(
                                        leading: Icon(Icons.album),
                                        title: Text('Intelligent Receipt'),
                                        subtitle:
                                        Text('Get unlimited automatically scans'),
                                      ),
                                    ),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: orientation == Orientation.portrait ? 1: 0.33,
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.125: 0.32),
                                    child:
                                    Card(
                                      child: ListTile(
                                        leading: Icon(Icons.album),
                                        title: Text('Intelligent Receipt'),
                                        subtitle: Text(
                                            'We have sent you an email, please click confirm'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),
                      ],
                    );
                }),
              );
            }));
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