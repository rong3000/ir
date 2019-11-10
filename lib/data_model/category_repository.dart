import 'package:intelligent_receipt/data_model/ir_repository.dart';
import "category.dart";
import "webservice.dart";
import "../user_repository.dart";
import 'dart:convert';

export 'category.dart';

class CategoryRepository extends IRRepository {
  List<Category> categories;
  bool _dataFetched = false;

  CategoryRepository(UserRepository userRepository)
    : super(userRepository) {
    categories = new List<Category>();
  }



  Future<DataResult> getCategoriesFromServer({bool forceRefresh = false}) async {
    if (_dataFetched && !forceRefresh) {
      return DataResult.success(categories);
    }

    if ((userRepository == null) || (userRepository.userId <= 0))
    {
      // Log an error // TODO: check for guid or something better
      return DataResult.fail(msg: "No user logged in.");
    }

    DataResult result = await webserviceGet(Urls.GetCategories, await getToken(), timeout: 5000);
    if (result.success) {
      Iterable l = result.obj;
      categories = l.map((model) => Category.fromJason(model)).toList();
      result.obj = categories;
    }

    _dataFetched = result.success;
    return result;
  }

  Future<DataResult> addCategory(String categoryName) async {
    DataResult result = await webservicePost(Urls.AddCategory, await getToken(), jsonEncode(categoryName));
    if (result.success) {
      Category category = Category.fromJason(result.obj);
      categories.add(category);
      result.obj = category;
    }

    return result;
  }

  Future<DataResult> updateCategory(Category category) async {
    DataResult result = await webservicePost(Urls.UpdateCategory, await getToken(), jsonEncode(category));
    if (result.success) {
      category = Category.fromJason(result.obj);
      result.obj = category;

      // update local cache
      for (int i = 0; i < categories.length; i++) {
        if (categories[i].id == category.id) {
          categories[i].categoryName = category.categoryName;
        }
      }
    }

    return result;
  }

  Future<DataResult> deleteCategory(int categoryId) async {
    DataResult result = await webservicePost(Urls.DeleteCategory + categoryId.toString(), await getToken(), jsonEncode(categoryId));
    if (result.success) {
      // delete local cache
      for (int i = 0; i < categories.length; i++) {
        if (categories[i].id == categoryId) {
          categories.removeAt(i);
          break;
        }
      }
    }

    return result;
  }
}