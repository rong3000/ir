import 'package:meta/meta.dart';

class ReceiptState {
  bool uploadinProgress;
  bool uploadSuccess;
  bool uploadFail;
  bool deleteInProgress;
  bool deleteSuccess;
  bool deleteFail;
  String errorMessage;

  ReceiptState({
    @required this.uploadinProgress,
    @required this.uploadSuccess,
    @required this.uploadFail,
    @required this.deleteInProgress,
    @required this.deleteSuccess,
    @required this.deleteFail,
    this.errorMessage
  });

  factory ReceiptState.uploading() {
    return ReceiptState(
      uploadinProgress: true,
      uploadSuccess: false,
      uploadFail: false,
      deleteInProgress: false,
      deleteSuccess: false,
      deleteFail: false,
    );
  }
  
  factory ReceiptState.uploadSucess() {
    return ReceiptState(
      uploadinProgress: false,
      uploadSuccess: true,
      uploadFail: false,
      deleteInProgress: false,
      deleteSuccess: false,
      deleteFail: false,
    );
  }
  
  factory ReceiptState.uploadFail() {
    return ReceiptState(
      uploadinProgress: false,
      uploadSuccess: false,
      uploadFail: true,
      deleteInProgress: false,
      deleteSuccess: false,
      deleteFail: false,
    );
  }

  factory ReceiptState.deleting() {
    return ReceiptState(
      uploadinProgress: false,
      uploadSuccess: false,
      uploadFail: false,
      deleteInProgress: true,
      deleteSuccess: false,
      deleteFail: false,
    );
  }

  factory ReceiptState.deleteSucess() {
    return ReceiptState(
      uploadinProgress: false,
      uploadSuccess: false,
      uploadFail: false,
      deleteInProgress: false,
      deleteSuccess: true,
      deleteFail: false,
    );
  }

  factory ReceiptState.deleteFail(String errorMsg) {
    return ReceiptState(
      uploadinProgress: false,
      uploadSuccess: false,
      uploadFail: false,
      deleteInProgress: false,
      deleteSuccess: false,
      deleteFail: true,
      errorMessage: errorMsg
    );
  }
}
