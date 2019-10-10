import 'package:bloc/bloc.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_event.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_state.dart';
import 'package:meta/meta.dart';


class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState>{
  ReceiptRepository _receiptRepository;

  ReceiptBloc({
    @required ReceiptRepository receiptRepository,
  })  : assert(receiptRepository != null),
        _receiptRepository = receiptRepository;

  @override
  ReceiptState get initialState => ReceiptState(uploadFail: false, uploadSuccess: false, uploadinProgress: false);

  @override
  Stream<ReceiptState> mapEventToState(ReceiptEvent event) async* {
   
    if (event is ReceiptUpload){
     yield* _handleReceiptUpload(event);
    }
    // More cases here for different events
  }


  Stream<ReceiptState> _handleReceiptUpload(ReceiptUpload event) async* {
    yield ReceiptState.uploading();
    var imageResult = await _receiptRepository.uploadReceiptImage(event.image); // TODO - need new API for upload image only linked to existing receipt
    if (imageResult.success){
      var receiptResult = await _receiptRepository.updateReceipt(event.receipt);
      //TODO: use data returned from image upload to merge with receipt data from form
      // may need to update json mapping, DB, entities and DTO's for added fields
      if (receiptResult.success){
        yield ReceiptState.uploadSucess();
      }
      else {
        yield ReceiptState.uploadFail();
      }
    }
    else {
      yield ReceiptState.uploadFail();
    }

  }

}
