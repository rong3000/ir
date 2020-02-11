import 'package:intelligent_receipt/data_model/news/newsitem.dart';
import 'package:meta/meta.dart';

@immutable
class NewsState {
  final bool isBusy;
  final bool loadSuccess;
  final bool loadFail;
  final bool dismissSuccess;
  final bool dismissFail;
  final List<NewsItem> newsItems;

  List<NewsItem> get news => newsItems;

  NewsState({this.isBusy, this.loadSuccess, this.loadFail, this.dismissSuccess, this.dismissFail, this.newsItems});

  factory NewsState.initialState(){
    return NewsState(isBusy: false, loadSuccess: false, loadFail: false, dismissSuccess: false, dismissFail: false, newsItems: []);
  }

  factory NewsState.isBusy(){
    return NewsState(isBusy: true, loadSuccess: false, loadFail: false, dismissSuccess: false, dismissFail: false, newsItems: []);
  }

  factory NewsState.loadSuccess(List<NewsItem> news){
    return NewsState(isBusy: false, loadSuccess: true, loadFail: false, dismissSuccess: false, dismissFail: false, newsItems: news);
  }

  factory NewsState.loadFail(){
    return NewsState(isBusy: false, loadSuccess: false, loadFail: true, dismissSuccess: false, dismissFail: false, newsItems: []);
  }

    factory NewsState.dismissSuccess(){
    return NewsState(isBusy: false, loadSuccess: true, loadFail: false, dismissSuccess: true, dismissFail: false, newsItems: []);
  }

  factory NewsState.dismissFail(){
    return NewsState(isBusy: false, loadSuccess: false, loadFail: true, dismissSuccess: false, dismissFail: true, newsItems: []);
  }
  
}