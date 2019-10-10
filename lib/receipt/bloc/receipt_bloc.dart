import 'package:bloc/bloc.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_event.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_state.dart';
import 'package:meta/meta.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  ReceiptRepository _receiptRepository;

  ReceiptBloc({
    @required ReceiptRepository receiptRepository,
  })  : assert(receiptRepository != null),
        _receiptRepository = receiptRepository;

  @override
  ReceiptState get initialState => ReceiptState(
      uploadFail: false, uploadSuccess: false, uploadinProgress: false);

  @override
  Stream<ReceiptState> mapEventToState(ReceiptEvent event) async* {
    if (event is ManualReceiptUpload) {
      yield* _handleManualReceiptUpload(event);
    }
    // More cases here for different events
  }

  Stream<ReceiptState> _handleManualReceiptUpload(ManualReceiptUpload event) async* {
    yield ReceiptState.uploading();
    var receiptResult = await _receiptRepository.addReceipts([event.receipt]);
    if (receiptResult.success) {
      yield ReceiptState.uploadSucess();
    } else {
      yield ReceiptState.uploadFail();
    }
  }
}
