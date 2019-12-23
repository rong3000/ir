import 'package:meta/meta.dart';

class ReceiptState {
  bool uploadinProgress;
  bool uploadSuccess;
  bool uploadFail;
  bool deleteInProgress;
  bool deleteSuccess;
  bool deleteFail;
  bool versionNotSupported;
  String errorMessage;

  ReceiptState({
    @required this.uploadinProgress,
    @required this.uploadSuccess,
    @required this.uploadFail,
    @required this.deleteInProgress,
    @required this.deleteSuccess,
    @required this.deleteFail,
    this.errorMessage,
    this.versionNotSupported
  });

  factory ReceiptState.uploading() {
    return ReceiptState(
      uploadinProgress: true,
      uploadSuccess: false,
      uploadFail: false,
      deleteInProgress: false,
      deleteSuccess: false,
      deleteFail: false,
      versionNotSupported: false
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
      versionNotSupported: false
    );
  }
  
  factory ReceiptState.uploadFail(String errorMsg) {
    return ReceiptState(
      uploadinProgress: false,
      uploadSuccess: false,
      uploadFail: true,
      deleteInProgress: false,
      deleteSuccess: false,
      deleteFail: false,
      errorMessage: errorMsg,
      versionNotSupported: false
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
      versionNotSupported: false
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
      versionNotSupported: false
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
      errorMessage: errorMsg,
      versionNotSupported: false
    );
  }

  factory ReceiptState.versionNotSupported() {
    return ReceiptState(
      uploadinProgress: false,
      uploadSuccess: false,
      uploadFail: false,
      deleteInProgress: false,
      deleteSuccess: false,
      deleteFail: false,
      versionNotSupported: true
    );
  }
}
