import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/news/newsitem.dart';

class _NewsItemView extends StatelessWidget {
  _NewsItemView({Key key, @required this.newsItem}) : super(key: key);

  final NewsItem newsItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          newsItem.text.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 2.0)),
        Text(
          newsItem.text.content,
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class NewsItemDescription extends StatelessWidget {
  NewsItemDescription({Key key, this.newsItem}) : super(key: key);

  final NewsItem newsItem;

  Widget getImage() {
    return Image.network(newsItem.imageUrl, frameBuilder:
        (BuildContext context, Widget child, int frame, bool syncLoaded) {
      if (syncLoaded || frame == 0) {
        return child;
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Icon(
          Icons.new_releases,
          size: 40,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
          constraints: BoxConstraints(maxHeight: 160, minHeight: 80),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: getImage(),
                flex: 5,
              ),
              Flexible(
                flex: 20,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
                  child: _NewsItemView(newsItem: newsItem),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
