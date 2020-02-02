import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NewsItemDisplay extends StatelessWidget {
  final Orientation orientation;

  NewsItemDisplay(this.orientation);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: Wrap(
        children: <Widget>[
          FractionallySizedBox(
            widthFactor: orientation == Orientation.portrait ? 1 : 0.33,
            child: Container(
              height: MediaQuery.of(context).size.height *
                  (orientation == Orientation.portrait ? 0.125 : 0.32),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.album),
                  title: AutoSizeText(
                    'Intelligent Receipt',
                    style: TextStyle(fontSize: 18),
                    minFontSize: 8,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: AutoSizeText(
                    'Invite your friends to join IR then receive more free automatically scansx',
                    style: TextStyle(fontSize: 18),
                    minFontSize: 8,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
