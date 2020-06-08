import 'package:json_annotation/json_annotation.dart';
import 'package:intelligent_receipt/data_model/ir_repository.dart';
import "webservice.dart";
import "../user_repository.dart";
import "enums.dart";
export 'data_result.dart';
export 'enums.dart';
import 'package:synchronized/synchronized.dart';
import 'dart:convert';

part 'product_repository.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

// Used for receipt list
class Product {
  int id;
  int userId;
  String name;
  int productTypeId;
  double price;
  int statusId;
  String description;
  bool isTaxable;
  bool isTaxIncludedInPrice;

  Product();

  factory Product.fromJason(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

class ProductRepository extends IRRepository {
  List<Product> products = new List<Product>();
  bool _dataFetched = false;
  Lock _lock = new Lock();

  ProductRepository(UserRepository userRepository) : super(userRepository);

  List<Product> getProductItems(ProductStatusType productStatus) {
    List<Product> selectedProducts = new List<Product>();
    _lock.synchronized(() {
      for (var i = 0; i < products.length; i++) {
        if (products[i].statusId == productStatus.index) {
          selectedProducts.add(products[i]);
        }
      }
    });
    return selectedProducts;
  }

  int getProductItemsCount(ProductStatusType productStatus) {
    int productCount = 0;
    _lock.synchronized(() {
      for (var i = 0; i < products.length; i++) {
        if (products[i].statusId == productStatus.index) {
          productCount++;
        }
      }
    });
    return productCount;
  }

  Product getProduct(int productId) {
    Product product;
    _lock.synchronized(() {
      for (var i = 0; i < products.length; i++) {
        if (products[i].id == productId) {
          product = products[i];
          break;
        }
      }
    });
    return product;
  }

  Future<DataResult> getProductsFromServer({bool forceRefresh = false}) async {
    DataResult result = new DataResult(false, "Unknown");
    await _lock.synchronized(() async {
      if (_dataFetched && !forceRefresh) {
        result = DataResult.success(products);
      } else if ((userRepository == null) || (userRepository.userGuid == null)) {
        // Log an error
        result = DataResult.fail();
      } else {
        result = await webserviceGet(Urls.GetProducts, await getToken(), timeout: 5000);
        if (result.success) {
          Iterable l = result.obj;
          products = l.map((model) => Product.fromJason(model)).toList();
          result.obj = products;
        }
      }

      _dataFetched = result.success;
    });

    return result;
  }

  Future<DataResult> addOrUpdateProduct(Product product) async {
    DataResult result = await webservicePost(Urls.AddOrUpdateProduct, await getToken(), jsonEncode(product));
    if (result.success) {
      Product newProduct = Product.fromJason(result.obj);
      result.obj = newProduct;
      _lock.synchronized(() {
        bool isNew = true;
        for (var i = 0; i < products.length; i++) {
          if (products[i].id == newProduct.id) {
            products[i] = newProduct;
            isNew = false;
            break;
          }
        }
        if (isNew) {
          products.add(newProduct);
        }
      });
    }

    return result;
  }

  Future<DataResult> deleteProduct(int productId, {updateLocal: true}) async {
    DataResult result = await webservicePost(Urls.DeleteProduct  + productId.toString(), await getToken(), "");
    if (result.success) {
      if (updateLocal) {
        for (var i = 0; i < products.length; i++) {
          if (products[i].id == productId) {
            products[i].statusId = ProductStatusType.Deleted.index;
            break;
          }
        }
      }
    }

    return result;
  }
}

