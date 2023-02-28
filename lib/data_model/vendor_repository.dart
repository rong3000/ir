import 'package:json_annotation/json_annotation.dart';
import 'package:intelligent_receipt/data_model/ir_repository.dart';
import "webservice.dart";
import "../user_repository.dart";
import "enums.dart";
export 'data_result.dart';
export 'enums.dart';
import 'package:synchronized/synchronized.dart';
import 'dart:convert';

part 'vendor_repository.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

// Used for receipt list
class Vendor {
  int id;
  int userId;
  String name;
  int vendorTypeId;
  int statusId;
  String contactName;
  String email;
  String phone;
  String mobilePhone;
  String fax;

  Vendor();

  factory Vendor.fromJason(Map<String, dynamic> json) => _$VendorFromJson(json);
  Map<String, dynamic> toJson() => _$VendorToJson(this);
}

class VendorRepository extends IRRepository {
  List<Vendor> vendors = new List<Vendor>();
  bool _dataFetched = false;
  Lock _lock = new Lock();

  VendorRepository(UserRepository userRepository) : super(userRepository);

  List<Vendor> getVendorItems(VendorStatusType vendorStatus) {
    List<Vendor> selectedVendors = new List<Vendor>();
    _lock.synchronized(() {
      for (var i = 0; i < vendors.length; i++) {
        if (vendors[i].statusId == vendorStatus.index) {
          selectedVendors.add(vendors[i]);
        }
      }
    });
    return selectedVendors;
  }

  int getVendorItemsCount(VendorStatusType vendorStatus) {
    int vendorCount = 0;
    _lock.synchronized(() {
      for (var i = 0; i < vendors.length; i++) {
        if (vendors[i].statusId == vendorStatus.index) {
          vendorCount++;
        }
      }
    });
    return vendorCount;
  }

  Vendor getVendor(int vendorId) {
    Vendor vendor;
    _lock.synchronized(() {
      for (var i = 0; i < vendors.length; i++) {
        if (vendors[i].id == vendorId) {
          vendor = vendors[i];
          break;
        }
      }
    });
    return vendor;
  }

  Future<DataResult> getVendorsFromServer({bool forceRefresh = false}) async {
    DataResult result = new DataResult(false, "Unknown");
    await _lock.synchronized(() async {
      if (_dataFetched && !forceRefresh) {
        result = DataResult.success(vendors);
      } else if ((userRepository == null) || (userRepository.userGuid == null)) {
        // Log an error
        result = DataResult.fail();
      } else {
        result = await webserviceGet(Urls.GetVendors, await getToken(), timeout: 5000);
        if (result.success) {
          Iterable l = result.obj;
          vendors = l.map((model) => Vendor.fromJason(model)).toList();
          result.obj = vendors;
        }
      }

      _dataFetched = result.success;
    });

    return result;
  }

  Future<DataResult> addOrUpdateVendor(Vendor vendor) async {
    DataResult result = await webservicePost(Urls.AddOrUpdateVendor, await getToken(), jsonEncode(vendor));
    if (result.success) {
      Vendor newVendor = Vendor.fromJason(result.obj);
      result.obj = newVendor;
      _lock.synchronized(() {
        bool isNew = true;
        for (var i = 0; i < vendors.length; i++) {
          if (vendors[i].id == newVendor.id) {
            vendors[i] = newVendor;
            isNew = false;
            break;
          }
        }
        if (isNew) {
          vendors.add(newVendor);
        }
      });
    }

    return result;
  }

  Future<DataResult> deleteVendor(int vendorId, {updateLocal: true}) async {
    DataResult result = await webservicePost(Urls.DeleteVendor  + vendorId.toString(), await getToken(), "");
    if (result.success) {
      if (updateLocal) {
        for (var i = 0; i < vendors.length; i++) {
          if (vendors[i].id == vendorId) {
            vendors[i].statusId = VendorStatusType.Deleted.index;
            break;
          }
        }
      }
    }

    return result;
  }
}

