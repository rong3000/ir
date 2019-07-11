import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = new TextEditingController();

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: <Widget>[
        Text('Superior Tech'),
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
