import 'package:flutter/widgets.dart';
import 'package:intelligent_receipt/data_model/archived_receipt_models/archivedreceiptdatarange.dart';
import 'package:intelligent_receipt/data_model/ir_repository.dart';
import "receipt.dart";
import 'report_repository.dart';
import "webservice.dart";
import "../user_repository.dart";
import 'dart:io';
import 'dart:convert';
import "enums.dart";
import 'package:synchronized/synchronized.dart';
export "receipt.dart";
export 'data_result.dart';
export 'enums.dart';
import 'message_code.dart';

class amountPair {
  double amount;
  int id;

  amountPair({this.amount, this.id});
}
class ReceiptRepository extends IRRepository {
  List<ReceiptListItem> receipts = new List<ReceiptListItem>();
  List<ReceiptListItem> selectedReceipts = new List<ReceiptListItem>();
  bool _dataFetched = false;
  Lock _lock = new Lock();

  ReceiptRepository(UserRepository userRepository) : super(userRepository);

  ReceiptListItem getReceiptItem(int receiptId) {
    ReceiptListItem receiptListItem;
    for (var i = 0; i < receipts.length; i++) {
      if (receipts[i].id == receiptId) {
        receiptListItem = receipts[i];
        break;
      }
    }
    return receiptListItem;
  }

  List<ReceiptListItem> getReceiptItems(ReceiptStatusType receiptStatus, SaleExpenseType saleExpenseType) {
    List<ReceiptListItem> selectedReceipts = new List<ReceiptListItem>();
    _lock.synchronized(() {
      for (var i = 0; i < receipts.length; i++) {
        if ((receipts[i].statusId == receiptStatus.index) && (receipts[i].receiptTypeId == saleExpenseType.index)) {
          selectedReceipts.add(receipts[i]);
        }
      }
    });
    return selectedReceipts;
  }

  List<ReceiptListItem> getReceiptItemsBetweenDateRange(Set<ReceiptStatusType> statusTypes, DateTime startDateTime, DateTime endDateTime) {
    List<ReceiptListItem> selectedReceipts = new List<ReceiptListItem>();
    for (var i = 0; i < receipts.length; i++) {
      if ((receipts[i].receiptDatetime.compareTo(startDateTime) >= 0) && (receipts[i].receiptDatetime.compareTo(endDateTime) <= 0) && statusTypes.contains(ReceiptStatusType.values[receipts[i].statusId])) {
        selectedReceipts.add(receipts[i]);
      }
    }
    return selectedReceipts;
  }

  List<ReceiptListItem> getReceiptItemsByRange(
      ReceiptStatusType receiptStatus, int start, int end) {
    List<ReceiptListItem> selectedReceipts = new List<ReceiptListItem>();
    _lock.synchronized(() {
      for (var i = 0; i < receipts.length; i++) {
        if (receipts[i].statusId == receiptStatus.index) {
          selectedReceipts.add(receipts[i]);
        }
      }
    });
    return selectedReceipts.getRange(start, end).toList();
  }

  int getReceiptItemsCount(ReceiptStatusType receiptStatus) {
    int receiptCount = 0;
    _lock.synchronized(() {
      for (var i = 0; i < receipts.length; i++) {
        if (receipts[i].statusId == receiptStatus.index) {
          receiptCount++;
        }
      }
    });
    return receiptCount;
  }

  Future<DataResult> getReceiptsFromServer({bool forceRefresh = false}) async {
    DataResult result = new DataResult(false, "Unknown");
    await _lock.synchronized(() async {
      if (_dataFetched && !forceRefresh) {
        result = DataResult.success(receipts);
      } else if ((userRepository == null) || (userRepository.userGuid == null)) {
        // Log an error
        result = DataResult.fail();
      } else {
        result = await webserviceGet(Urls.GetReceipts, await getToken(), timeout: 5000);
        if (result.success) {
          Iterable l = result.obj;
          receipts = l.map((model) => ReceiptListItem.fromJason(model)).toList();
          result.obj = receipts;
        }
      }

      _dataFetched = result.success;
    });

    return result;
  }

  Future<DataResult> getReceipt(int receiptId) async {
    DataResult result =
        await webserviceGet(Urls.GetReceipt + receiptId.toString(), await getToken());
    if (result.success) {
      result.obj = Receipt.fromJason(result.obj);
    }

    return result;
  }

  Future<DataResult> updateReceipt(Receipt receipt) async {
    DataResult result =
        await webservicePost(Urls.UpdateReceipt, await getToken(), jsonEncode(receipt));
    if (result.success) {
      Receipt newReceipt = Receipt.fromJason(result.obj);
      _lock.synchronized(() {
        // update local cache
        for (int j = 0; j < receipts.length; j++) {
          if (receipts[j].id == newReceipt.id) {
            receipts[j] = newReceipt;
            break;
          }
        }
      });
    }

    return result;
  }

  Future<DataResult> updateReceiptListItem(ReceiptListItem receipt) async {
    DataResult result =
    await webservicePost(Urls.UpdateReceiptListItem, await getToken(), jsonEncode(receipt));
    if (result.success) {
      Receipt newReceipt = Receipt.fromJason(result.obj);
      _lock.synchronized(() {
        // update local cache
        for (int j = 0; j < receipts.length; j++) {
          if (receipts[j].id == newReceipt.id) {
            receipts[j] = newReceipt;
            break;
          }
        }
      });
    }

    return result;
  }

  Future<DataResult> addReceipts(List<Receipt> newReceipts) async {
    DataResult result =
        await webservicePost(Urls.AddReceipts, await getToken(), jsonEncode(newReceipts));
    if (result.success) {
      Iterable l = result.obj;
      var addedReceipts = l.map((model) => ReceiptListItem.fromJason(model)).toList();
      for (var receipt in addedReceipts){
        _lock.synchronized(() {
          receipts.add(receipt);
        });
      }
    }

    return result;
  }

  Future<DataResult> uploadReceiptImage(File imageFile, { @required SaleExpenseType saleExpenseType }) async {
    if ((userRepository == null) || (userRepository.userGuid == null)) {
      // Log an error
      return DataResult.fail(msg: "No user logged in.");
    }

    var url = Urls.UploadReceiptImages + saleExpenseType.index.toString() + "/";
    DataResult result = await uploadFile(
        url,
        await getToken(),
        imageFile, timeout: 10000);
    if (result.success) {
      Iterable l = result.obj;
      List<Receipt> newReceipts =
          l.map((model) => Receipt.fromJason(model)).toList();
      if (newReceipts.length > 0) {
        Receipt receipt = newReceipts[0];
        // insert the new receipt into the receipt list
        _lock.synchronized(() {
          receipts.add(receipt);
        });
        result.obj = receipt;
      } else {
        result.obj = null;
      }
    }

    return result;
  }

  Future<DataResult> deleteReceipts(List<int> receiptIds) async {
    DataResult result =
        await webservicePost(Urls.DeleteReceipts, await getToken(), jsonEncode(receiptIds), timeout: 2000);
    if (result.success) {
      // Delete the local cache of the receipts
      for (int i = 0; i < receiptIds.length; i++) {
        _lock.synchronized(() {
          for (int j = 0; j < receipts.length; j++) {
            if (receipts[j].id == receiptIds[i]) {
              receipts.removeAt(j);
              break;
            }
          }
        });
      }
    }

    return result;
  }

  Future<Image> getNetworkImage(String url) async {
    final token = await getToken();

    return await getImageFromNetwork(url, token);
  }

  Future<DataResult> archiveReceipt(int receiptId) async {
    var url = Urls.ArchiveReceipt + receiptId.toString();
    var result = await webservicePost(url, await getToken(), null);
    if (result.success) {
      for (int j = 0; j < receipts.length; j++) {
        if (receipts[j].id == receiptId) {
          receipts[j].statusId = ReceiptStatusType.Archived.index;
          break;
        }
      }
    }
    return result;
  }

  Future<DataResult> unArchiveReceipt(int receiptId) async {
    var url = Urls.UnArchiveReceipt + receiptId.toString();
    var result = await webservicePost(url, await getToken(), null);
    if (result.success) {
      for (int j = 0; j < receipts.length; j++) {
        if (receipts[j].id == receiptId) {
          receipts[j].statusId = ReceiptStatusType.Reviewed.index;
          break;
        }
      }
    }
    return result;
  }

  Future<DataResult> getArchivedReceiptMetaData(SaleExpenseType saleExpenseType) async {
    var params = {
      'receiptType' : saleExpenseType.index.toString(),
    };

    var query = Uri(queryParameters: params).query;
    var url = Urls.ArchiveReceiptMetaData  + '?' + query;
    var result = await webserviceGet(url, await getToken());
    
    if (result.success) {
      var data = ArchivedReceiptDataRange.fromJson(result.obj);
      result.obj = data;
    }

    return result;    
  }

  Future<DataResult> getArchivedReceipts(String yearMonth, SaleExpenseType saleExpenseType) async {
    var year = int.parse(yearMonth.substring(0,4));
    var month = int.parse(yearMonth.substring(4));
    var fromDate = DateTime(year, month);
    var toDate = DateTime(year, month + 1);//.add(Duration(days: -1));
    
    var params = {
      'receiptType' : saleExpenseType.index.toString(),
      'statusType' : ReceiptStatusType.Archived.index.toString(),
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String()
    };
    
    var query = Uri(queryParameters: params).query;  
    var url =  Urls.GetReceipts + '?' + query;
    var result = await webserviceGet(url, await getToken());
    
    if (result.success) {
      Iterable l = result.obj;
      var r = l.map((model) => ReceiptListItem.fromJason(model)).toList();
      result.obj = r;
    }

    return result;    
  }
}
