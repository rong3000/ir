import 'package:intelligent_receipt/data_model/ir_repository.dart';
import 'package:intelligent_receipt/data_model/news/newsitem.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';
import 'package:intelligent_receipt/user_repository.dart';

class NewsRepository extends IRRepository {
  
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
    }
    return result; 
  }


  Future<bool> dismissNewsItem(int itemId) async {
    var url = Urls.MarkNewsItemsRead + itemId.toString();
    
    var dataResult = await webservicePost(url, await getToken(), null);

    if (dataResult.success){
      return true;
    }
    return false;
  }
}