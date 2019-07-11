import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final myController = TextEditingController();

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: <Widget>[
//        Icon(
//          Icons.search,
//        ),
        Text('Superior Tech'),
        TextField(
          controller: myController,
          decoration: InputDecoration(hintText: "This is a hint"),
        ),
        RaisedButton(
          onPressed: () {
            print('clicked');
          },
          child: Text('Search'),

        )
      ],
      ),
    );
  }
}
