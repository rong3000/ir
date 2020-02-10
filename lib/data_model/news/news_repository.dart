import 'package:intelligent_receipt/data_model/ir_repository.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';
import 'package:intelligent_receipt/user_repository.dart';

class NewsRepository extends IRRepository {
  
  NewsRepository(UserRepository userRepository) : super(userRepository);

  Future<DataResult> getNewsItems() async {
    var url = Urls.GetNewsItems;
    var token = await getToken();

    var result = await  webserviceGet(url, token);


    if (result.success){
      
    }

    return result; 
  }   
}