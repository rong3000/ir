import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final String name;
  final bool verified;
  SearchBar({Key key, @required this.name, @required this.verified}) : super(key: key);
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
//        Text('${name}(${widget.verified ? '' : 'Email not verified'})'),
        AutoSizeText(
          '${name} ${widget.verified ? '' : '(Not Verified)'}',
          style: TextStyle(fontSize: 16),
          minFontSize: 6,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
//        Expanded(
//          flex: 1,
//          child: TextField(
//            controller: _controller,
//            decoration: new InputDecoration(
//              hintText: 'Start search',
//              icon: Icon(Icons.search),
//            ),
//          ),
//        ),
//        RaisedButton(
//          onPressed: () {
//            print(_controller.text);
//          },
//          child: Text('Search'),
//
//        ),
      ],
      ),
    );
  }
}
