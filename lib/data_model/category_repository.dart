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

  Future<bool> getCategoriesFromServer({bool forceRefresh = false}) async {
    //var image = await ImagePicker.pickImage(source: ImageSource.camera);
    //await this.uploadReceiptFile(image);
    if (_dataFetched && !forceRefresh) {
      return true;
    }

    if ((_userRepository == null) || (_userRepository.userId <= 0))
    {
      // Log an error
      return false;
    }

    WebServiceResult result = await webserviceGet(Urls.GetCategories + _userRepository.userId.toString(), "");
    if (result.success) {
      Iterable l = result.jasonObj;
      categories = l.map((model) => Category.fromJason(model)).toList();
    }

    _dataFetched = result.success;
    return result.success;
  }

  Future<Category> addCategory(String categoryName) async {
    Category category = null;
    WebServiceResult result = await webservicePost(Urls.AddCategory + _userRepository.userId.toString(), "", jsonEncode(categoryName));
    if (result.success) {
      category = Category.fromJason(result.jasonObj);
      categories.add(category);
    }

    return category;
  }

  Future<Category> updateCategory(Category category) async {
    WebServiceResult result = await webservicePost(Urls.UpdateCategory + _userRepository.userId.toString(), "", jsonEncode(category));
    if (result.success) {
      category = Category.fromJason(result.jasonObj);

      // update local cache
      for (int i = 0; i < categories.length; i++) {
        if (categories[i].id == category.id) {
          categories[i].categoryName = category.categoryName;
        }
      }
    }

    return category;
  }

  Future<bool> deleteCategory(int categoryId) async {
    WebServiceResult result = await webservicePost(Urls.DeleteCategory + categoryId.toString(), "", jsonEncode(categoryId));
    if (result.success) {
      // delete local cache
      for (int i = 0; i < categories.length; i++) {
        if (categories[i].id == categoryId) {
          categories.removeAt(i);
          break;
        }
      }
    }

    return result.success;
  }
}