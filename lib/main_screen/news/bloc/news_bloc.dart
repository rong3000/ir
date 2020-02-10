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
    // TODO: implement mapEventToState

    if (event is LoadNewsItems){
      yield* _handleLoadNewsItems(event);
    } else if (event is LoadNewsItemsSucess){

    }

  }

  Stream<NewsState> _handleLoadNewsItems (LoadNewsItems event) async* {

    var result = await _newsRepository.getNewsItems();
    if (result.success){
      yield NewsState.loadSuccess();
    }
  }

}