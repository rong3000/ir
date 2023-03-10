import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:intelligent_receipt/data_model/news/news_repository.dart';
import 'package:intelligent_receipt/main_screen/news/bloc/news_event.dart';
import 'package:intelligent_receipt/main_screen/news/bloc/news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState>{
  NewsRepository _newsRepository;

  NewsBloc({ @required NewsRepository newsRepository }): assert(newsRepository != null),
        _newsRepository = newsRepository;
  
  @override
  NewsState get initialState => NewsState.initialState();

  @override
  Stream<NewsState> mapEventToState(NewsEvent event) async* {

    if (event is LoadNewsItems){
      yield* _handleLoadNewsItems(event);
    } else if (event is DismissNewsItems){
      yield* _handleDismissNewsItems(event);
    }
  }

  Stream<NewsState> _handleLoadNewsItems (LoadNewsItems event) async* {

    var result = await _newsRepository.getNewsItems();
    if (result != null){
      yield NewsState.loadSuccess(_newsRepository.newsItems);
    } else {
      yield NewsState.loadFail(_newsRepository.newsItems);
    }
  }

  Stream<NewsState> _handleDismissNewsItems(DismissNewsItems event) async* {
    // Dont await this - let it work in background, item will be removed from view regardless
    _newsRepository.dismissNewsItem(event.itemId);
    yield NewsState.dismissSuccess(_newsRepository.newsItems);
  }

}