import 'package:flutter/material.dart';
import 'package:intelligent_receipt/pages/search_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: SearchBar(),
//      body: SearchBar(),
      body: Stack(
        children: <Widget>[
//          SearchBar(),
          MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: Text('Home'),
          ),
          Text('xxxxxxxxxx'),
        ],
      ),
    );
  }
}
