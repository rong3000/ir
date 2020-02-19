import 'package:intelligent_receipt/data_model/ir_repository.dart';
import 'package:intelligent_receipt/data_model/news/newsitem.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';
import 'package:intelligent_receipt/user_repository.dart';

class NewsRepository extends IRRepository {
  
  // This property is here to track any dismissed items that have not yet been dismissed on server
  // due to network issue/ Device offline etc. 
  Set<int> _readItems = {};

  List<NewsItem> _newsItems = [];
  List<NewsItem> get newsItems => _newsItems.where((item) => !_readItems.contains(item.id)).toList();
  set newsItems(List<NewsItem> items) {
    _newsItems = items;
  }
  
  NewsRepository(UserRepository userRepository) : super(userRepository);
  
  Future<List<NewsItem>> getNewsItems() async {
    var language = userRepository.preferencesRepository.getPreferredLanguage();
    var query = '?localeCode=$language';
    var url = Urls.GetNewsItems + query;
    var token = await getToken();

    var dataResult = await webserviceGet(url, token);

    var result;
    if (dataResult.success){
      Iterable l = dataResult.obj;
      result = l.map((model) => NewsItem.fromJson(model)).toList();
      newsItems = result;

      // Clean up any items that failed to dismiss (offline etc)
      if (_readItems.isNotEmpty){
        _readItems.forEach((failedItemId) {
          // Don't await this, let it attempt to clean up dismissed news items in the background
          dismissNewsItem(failedItemId); 
        });
      }
    }
    return result; 
  }


  Future<bool> dismissNewsItem(int itemId) async {
    var url = Urls.MarkNewsItemsRead + itemId.toString();
    
    _readItems.add(itemId);
    var dataResult = await webservicePost(url, await getToken(), null);

    if (dataResult.success){
      _readItems.remove(itemId);
      _newsItems.removeWhere((item) => item.id == itemId);
      return true;
    }
    return false;
  }
}