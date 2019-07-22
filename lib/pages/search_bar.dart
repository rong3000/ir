import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final String name;
  SearchBar({Key key, @required this.name}) : super(key: key);
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = new TextEditingController();

  String get name => widget.name;

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: <Widget>[
        Text(name),
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
            print(_controller.text);
          },
          child: Text('Search'),

        ),
      ],
      ),
    );
  }
}
