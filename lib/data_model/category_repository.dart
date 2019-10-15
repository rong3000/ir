import "category.dart";
import "webservice.dart";
import "../user_repository.dart";
import 'dart:convert';

export 'category.dart';

class CategoryRepository {
  List<Category> categories;
  final UserRepository _userRepository;
  bool _dataFetched = false;

  CategoryRepository(UserRepository userRepository)
    : _userRepository = userRepository {
    categories = new List<Category>();
  }

  Future<DataResult> getCategoriesFromServer({bool forceRefresh = false}) async {
    if (_dataFetched && !forceRefresh) {
      return DataResult.success(categories);
    }

    if ((_userRepository == null) || (_userRepository.userId <= 0))
    {
      // Log an error
      return DataResult.fail(msg: "No user logged in.");
    }

    DataResult result = await webserviceGet(Urls.GetCategories + _userRepository.userId.toString(), "", timeout: 5000);
    if (result.success) {
      Iterable l = result.obj;
      categories = l.map((model) => Category.fromJason(model)).toList();
      result.obj = categories;
    }

    _dataFetched = result.success;
    return result;
  }

  Future<DataResult> addCategory(String categoryName) async {
    DataResult result = await webservicePost(Urls.AddCategory + _userRepository.userId.toString(), "", jsonEncode(categoryName));
    if (result.success) {
      Category category = Category.fromJason(result.obj);
      categories.add(category);
      result.obj = category;
    }

    return result;
  }

  Future<DataResult> updateCategory(Category category) async {
    DataResult result = await webservicePost(Urls.UpdateCategory + _userRepository.userId.toString(), "", jsonEncode(category));
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
    DataResult result = await webservicePost(Urls.DeleteCategory + categoryId.toString(), "", jsonEncode(categoryId));
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