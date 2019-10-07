import 'package:meta/meta.dart';

class ReceiptState {
  bool uploadinProgress;
  bool uploadSuccess;
  bool uploadFail;

  ReceiptState({
    @required this.uploadinProgress,
    @required this.uploadSuccess,
    @required this.uploadFail,
  });

  factory ReceiptState.uploading() {
    return ReceiptState(
      uploadinProgress: true,
      uploadSuccess: false,
      uploadFail: false,
    );
  }
  
  factory ReceiptState.uploadSucess() {
    return ReceiptState(
      uploadinProgress: false,
      uploadSuccess: true,
      uploadFail: false,
    );
  }
  
  factory ReceiptState.uploadFail() {
    return ReceiptState(
      uploadinProgress: false,
      uploadSuccess: false,
      uploadFail: true,
    );
  }
}
