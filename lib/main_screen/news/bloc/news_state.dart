import 'package:meta/meta.dart';

@immutable
class NewsState {
  final bool isBusy;
  final bool loadSuccess;
  final bool loadFail;
  final bool dismissSuccess;
  final bool dismissFail;

  NewsState({this.isBusy, this.loadSuccess, this.loadFail, this.dismissSuccess, this.dismissFail});

  factory NewsState.initialState(){
    return NewsState(isBusy: false, loadSuccess: false, loadFail: false, dismissSuccess: false, dismissFail: false);
  }

  factory NewsState.isBusy(){
    return NewsState(isBusy: true, loadSuccess: false, loadFail: false, dismissSuccess: false, dismissFail: false);
  }

  factory NewsState.loadSuccess(){
    return NewsState(isBusy: false, loadSuccess: true, loadFail: false, dismissSuccess: false, dismissFail: false);
  }

  factory NewsState.loadFail(){
    return NewsState(isBusy: false, loadSuccess: false, loadFail: true, dismissSuccess: false, dismissFail: false);
  }

    factory NewsState.dismissSuccess(){
    return NewsState(isBusy: false, loadSuccess: true, loadFail: false, dismissSuccess: true, dismissFail: false);
  }

  factory NewsState.dismissFail(){
    return NewsState(isBusy: false, loadSuccess: false, loadFail: true, dismissSuccess: false, dismissFail: true);
  }
  
}