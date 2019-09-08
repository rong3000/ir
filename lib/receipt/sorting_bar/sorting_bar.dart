import 'package:flutter/material.dart';

class SortingBar extends StatefulWidget {
  SortingBar({Key key}) : super(key: key);
  @override
  _SortingBarState createState() => _SortingBarState();
}

class _SortingBarState extends State<SortingBar> {
  final TextEditingController _controller = new TextEditingController();

//  String get name => widget.name;

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: <Widget>[
        Expanded(
          flex: 1,
          child: TextField(
            controller: _controller,
            decoration: new InputDecoration(
              hintText: 'Start search',
              icon: Icon(Icons.search),
            ),
          ),
        ),
        RaisedButton(
          onPressed: () {
            someObjects.sort((a, b) => a.someProperty.compareTo(b.someProperty));
          },
          child: Text('Search'),

        ),
      ],
      ),
    );
  }
}
