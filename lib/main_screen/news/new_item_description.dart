import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/news/newsitem.dart';

class _NewsItemView extends StatelessWidget {
  _NewsItemView({Key key, @required this.newsItem}) : super(key: key);

  final NewsItem newsItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${newsItem.text.title}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                '${newsItem.text.content}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        // Expanded( TODO: consider using this to inform user that the item conatins a link or similar
        //   flex: 1,
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: <Widget>[
        //       Text(
        //         '${newsItem.imageUrl}',
        //         style: const TextStyle(
        //           fontSize: 12.0,
        //           color: Colors.black87,
        //         ),
        //       ),
        //       Text(
        //         '${newsItem.imageUrl} · ${newsItem.touchAction} ★',
        //         style: const TextStyle(
        //           fontSize: 12.0,
        //           color: Colors.black54,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}

class NewsItemDescription extends StatelessWidget {
  NewsItemDescription({
    Key key,
    //this.thumbnail,
    this.newsItem,
    this.dismissCallback
  }) : super(key: key);

  //final Widget thumbnail;
  final NewsItem newsItem;
  double dragStartX;
  double dragStartY;
  bool dragEnoughforClose = false;
  final double swipeDistanceThreshold = 70;

  Function dismissCallback;

  Widget getImage() {
    return Image.network(newsItem.imageUrl, frameBuilder:
        (BuildContext context, Widget child, int frame, bool syncLoaded) {
      if (syncLoaded || frame == 0) {
        return child;
      }
      return Icon(
        Icons.new_releases,
        size: 40,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails startDetails){
        dragStartY = startDetails.globalPosition.dy;
        dragStartX = startDetails.globalPosition.dx;
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (dragEnoughforClose){
          dismissCallback(newsItem.id);
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails updateDetails) {
        if (updateDetails.globalPosition.dx - dragStartX > swipeDistanceThreshold){
          dragEnoughforClose = true;
        } else {
          dragEnoughforClose = false;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.0,
                child: getImage(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 2.0, 0.0),
                  child: _NewsItemView(newsItem: newsItem),
                ),
              ),
              GestureDetector(
                onTap: () {
                  dismissCallback(newsItem.id);
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 10, 0),
                  child: SizedBox(
                    width: 20,
                    child: Icon(Icons.close),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
