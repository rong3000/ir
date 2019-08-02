import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Column(
          children: <Widget>[
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Text("Reports"),
            ),
            Flexible(
                fit: FlexFit.tight,
                child: Wrap(
                  children: <Widget>[
                    FractionallySizedBox(
                      widthFactor:
                          orientation == Orientation.portrait ? 1 : 0.33,
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            (orientation == Orientation.portrait ? 0.1 : 0.2),
                        child: Card(
                          child: ListTile(
                            leading: Icon(Icons.album),
                            title: Text('Intelligent Receipt'),
                            subtitle: Text(
                                'Invite your friends to join IR then receive more free automatically scans'),
                          ),
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor:
                          orientation == Orientation.portrait ? 1 : 0.33,
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            (orientation == Orientation.portrait ? 0.1 : 0.2),
                        child: Card(
                          child: ListTile(
                            leading: Icon(Icons.album),
                            title: Text('Intelligent Receipt'),
                            subtitle: Text('Get unlimited automatically scans'),
                          ),
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor:
                          orientation == Orientation.portrait ? 1 : 0.33,
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            (orientation == Orientation.portrait ? 0.1 : 0.2),
                        child: Card(
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
                )),
          ],
        );
      }),
    );
  }
}
