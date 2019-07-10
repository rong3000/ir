import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: <Widget>[
//        Icon(
//          Icons.search,
//        ),
        Text('Superior Tech'),
      ],
      ),
    );
  }
}
