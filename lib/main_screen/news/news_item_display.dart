import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/news/newsitem.dart';
import 'package:intelligent_receipt/main_screen/news/bloc/news_bloc.dart';
import 'package:intelligent_receipt/main_screen/news/bloc/news_event.dart';
import 'package:intelligent_receipt/main_screen/news/bloc/news_state.dart';
import 'package:intelligent_receipt/main_screen/news/new_item_description.dart';

class NewsItemDisplay extends StatefulWidget {
  final Orientation orientation;
  NewsItemDisplay(this.orientation);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NewsItemDisplayState();
  }
}

class _NewsItemDisplayState extends State<NewsItemDisplay> {
  NewsBloc _newsBloc;

  _NewsItemDisplayState();

  @override
  void initState() {
    _newsBloc = BlocProvider.of<NewsBloc>(context);
    _newsBloc.dispatch(LoadNewsItems());
    super.initState();
  }

  List<Widget> getNewsItemDisplayWidgets(List<NewsItem> newsItems) {
    var widgets = List<Widget>();
    for (var item in newsItems) {
      widgets.add(NewsItemDescription(newsItem: item));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<NewsBloc>(context),
      builder: (BuildContext context, NewsState state) {
        return Expanded(
          child: ListView(
            children: getNewsItemDisplayWidgets(state.newsItems),
          ),
        );
      },
    );
  }
}
