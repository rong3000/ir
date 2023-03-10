import 'package:bloc/bloc.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_event.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_state.dart';
import 'package:meta/meta.dart';
import 'package:intelligent_receipt/data_model/http_statuscode.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  ReceiptRepository _receiptRepository;

  ReceiptBloc({
    @required ReceiptRepository receiptRepository,
  })  : assert(receiptRepository != null),
        _receiptRepository = receiptRepository;

  @override
  ReceiptState get initialState => ReceiptState(
      uploadFail: false, uploadSuccess: false, uploadinProgress: false, deleteFail: false, deleteInProgress: false, deleteSuccess: false);

  @override
  Stream<ReceiptState> mapEventToState(ReceiptEvent event) async* {
    if (event is ManualReceiptUpload) {
      yield* _handleManualReceiptUpload(event);
    }
    else if (event is ManualReceiptUpdate){
      yield*  _handleManualReceiptUpdate(event);
    }
    else if (event is ManualReceiptDelete){
      yield*  _handleManualReceiptDelete(event);
    }
    // More cases here for different events
  }

  Stream<ReceiptState> _handleManualReceiptUpload(ManualReceiptUpload event) async* {
    yield ReceiptState.uploading();
    var receiptResult = await _receiptRepository.addReceipts([event.receipt]);
    if (receiptResult.success) {
      yield ReceiptState.uploadSucess();
    } else if (receiptResult.messageCode == HTTPStatusCode.UNSUPPORTED_VERSION) {
      yield ReceiptState.versionNotSupported();
    } else {
      yield ReceiptState.uploadFail(receiptResult.message);
    }
  }

  Stream<ReceiptState> _handleManualReceiptUpdate(ManualReceiptUpdate event) async* {
    yield ReceiptState.uploading();
    var receiptResult = await _receiptRepository.updateReceipt(event.receipt);
    if (receiptResult.success) {
      yield ReceiptState.uploadSucess();
    } else if (receiptResult.messageCode == HTTPStatusCode.UNSUPPORTED_VERSION) {
      yield ReceiptState.versionNotSupported();
    } else {
      yield ReceiptState.uploadFail(receiptResult.message);
    }
  }

  Stream<ReceiptState> _handleManualReceiptDelete(ManualReceiptDelete event) async* {
    yield ReceiptState.deleting();
    var receiptResult = await _receiptRepository.deleteReceipts([event.receipt.id]);
    if (receiptResult.success) {
      yield ReceiptState.deleteSucess();
    } else if (receiptResult.messageCode == HTTPStatusCode.UNSUPPORTED_VERSION) {
      yield ReceiptState.versionNotSupported();
    } else {
      yield ReceiptState.deleteFail(receiptResult.message);
    }
  }
}
