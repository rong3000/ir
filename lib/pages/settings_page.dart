
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation){
        return
          Column(
            children: <Widget>[
              Flexible(child: Row(
                children: <Widget>[
                  Expanded(
                    child: FractionallySizedBox(
                      child: FractionallySizedBox(
                        widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                        child: Card(
                          child: ListTile(
                            title: Text('Add Your (First) Receipt'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FractionallySizedBox(
                      child: FractionallySizedBox(
                        widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                        child: Card(
                          child: ListTile(
                            title: Text('Add Your (First) Receipt'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),),
              Flexible(child: Row(
                children: <Widget>[
                  Expanded(
                    child: FractionallySizedBox(
                      child: FractionallySizedBox(
                        widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                        child: Card(
                          child: ListTile(
                            title: Text('Add Your (First) Receipt'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FractionallySizedBox(
                      child: FractionallySizedBox(
                        widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                        child: Card(
                          child: ListTile(
                            title: Text('Add Your (First) Receipt'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),),
              Flexible(
                  fit: FlexFit.tight,
                  child: Wrap(
                    children: <Widget>[
                      FractionallySizedBox(
                        widthFactor: orientation == Orientation.portrait ? 1: 0.33,
                        child: Card(
                          child: ListTile(
                            title: Text('Add Your (First) Receipt'),
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: orientation == Orientation.portrait ? 1: 0.33,
                        child: Card(
                          child: ListTile(
                            title: Text('Add Your (First) Receipt'),
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: orientation == Orientation.portrait ? 1: 0.33,
                        child: Card(
                          child: ListTile(
                            title: Text('Add Your (First) Receipt'),
                          ),
                        ),
                      ),
                    ],
                  )
              ),

//          Flexible(
//            flex: 10,
//            fit: FlexFit.tight,
//            child: Column(
//              children: <Widget>[
//                Flexible(
//                  fit: FlexFit.tight,
//                  child: Card(
//                    child: Column(
//                      mainAxisSize: MainAxisSize.min,
//                      children: <Widget>[
//                        const ListTile(
//                          leading: Icon(Icons.album),
//                          title: Text('Intelligent Receipt'),
//                          subtitle: Text(
//                              'Invite your friends to join IR then receive more free automatically scans'),
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
//                Flexible(
//                  fit: FlexFit.tight,
//                  child: Card(
//                    child: Column(
//                      mainAxisSize: MainAxisSize.min,
//                      children: <Widget>[
//                        const ListTile(
//                          leading: Icon(Icons.album),
//                          title: Text('Intelligent Receipt'),
//                          subtitle:
//                          Text('Get unlimited automatically scans'),
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
//                Flexible(
//                  fit: FlexFit.tight,
//                  child: Card(
//                    child: Column(
//                      mainAxisSize: MainAxisSize.min,
//                      children: <Widget>[
//                        const ListTile(
//                          leading: Icon(Icons.album),
//                          title: Text('Intelligent Receipt'),
//                          subtitle: Text(
//                              'We have sent you an email, please click confirm'),
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
//              ],
//            ),
//          ),
            ],
          );
      }),
    );
  }
}
