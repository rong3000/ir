import 'package:intelligent_receipt/data_model/news/newsitem.dart';
import 'package:meta/meta.dart';

@immutable
class NewsState {
  final bool isBusy;
  final bool loadSuccess;
  final bool loadFail;
  final bool dismissSuccess;
  final List<NewsItem> newsItems;

  List<NewsItem> get news => newsItems;

  NewsState({this.isBusy, this.loadSuccess, this.loadFail, this.dismissSuccess, this.newsItems});

  factory NewsState.initialState(){
    return NewsState(isBusy: false, loadSuccess: false, loadFail: false, dismissSuccess: false, newsItems: []);
  }

  factory NewsState.loadSuccess(List<NewsItem> news){
    return NewsState(isBusy: false, loadSuccess: true, loadFail: false, dismissSuccess: false, newsItems: news);
  }

  factory NewsState.loadFail(List<NewsItem> news){
    return NewsState(isBusy: false, loadSuccess: false, loadFail: true, dismissSuccess: false, newsItems: news);
  }

  factory NewsState.dismissSuccess(List<NewsItem> news){
    return NewsState(isBusy: false, loadSuccess: true, loadFail: false, dismissSuccess: true, newsItems: news);
  }
  
}