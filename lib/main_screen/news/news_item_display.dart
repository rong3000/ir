import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/main_screen/news/bloc/news_bloc.dart';
import 'package:intelligent_receipt/main_screen/news/bloc/news_event.dart';
import 'package:intelligent_receipt/main_screen/news/bloc/news_state.dart';


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


  List<Widget> getNewsItemDisplayWidgets(NewsState state){

    // for (var item in newsItems){
    //   yield 
    // }
    var items = state.news;

    return <Widget>[
              FractionallySizedBox(
                widthFactor: widget.orientation == Orientation.portrait ? 1 : 0.33,
                child: Container(
                  height: MediaQuery.of(context).size.height *
                      (widget.orientation == Orientation.portrait ? 0.125 : 0.32),
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
                        'Invite your friends to join IR then receive more free automatically scans',
                        style: TextStyle(fontSize: 18),
                        minFontSize: 8,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ];
  
  }


  @override
  Widget build(BuildContext context) {
    
    return BlocBuilder(
      bloc: BlocProvider.of<NewsBloc>(context),
      builder: (BuildContext context, NewsState state) {
        
        
        
        return Flexible(
          fit: FlexFit.tight,
          child: Wrap(
            children: getNewsItemDisplayWidgets(state)
          ),
        );
      },
      );
    
  }
}
