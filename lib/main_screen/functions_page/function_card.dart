import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

class FunctionCard extends StatelessWidget {
  Widget _nextWidget;
  String _title;
  String _description;

  FunctionCard(this._nextWidget, this._title, this._description);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return _nextWidget;
          }),
        )
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
          child: Container(
            constraints: BoxConstraints(maxHeight: 160, minHeight: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center (
                  child:Text(
                    _title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )),
                const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                Text(
                  _description,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

