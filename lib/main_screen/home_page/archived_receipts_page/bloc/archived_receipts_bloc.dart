import 'package:bloc/bloc.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/main_screen/home_page/archived_receipts_page/bloc/archived_receipts_events.dart';
import 'package:intelligent_receipt/main_screen/home_page/archived_receipts_page/bloc/archived_receipts_state.dart';
import 'package:meta/meta.dart';

class ArchivedReceiptsBloc extends Bloc<ArchivedReceiptsEvent, ArchivedReceiptsState> {
  ReceiptRepository _receiptRepository;

  ArchivedReceiptsBloc({
    @required ReceiptRepository receiptRepository,
  })  : assert(receiptRepository != null),
        _receiptRepository = receiptRepository;

  @override
  ArchivedReceiptsState get initialState => GetArchiveMetaDataInitial();

  @override
  Stream<ArchivedReceiptsState> mapEventToState(ArchivedReceiptsEvent event) async* {
    if (event is GetArchiveMetaData) {
      yield* _getArchivedReceiptsMetaData(event);
    }
    else if (event is GetArchivedReceipts){
      yield*  _handleGetArchivedReceipts(event);
    }
    else if (event is UnArchivedReceipt){
      yield*  _handleUnArchivedReceipt(event);
    }
    // More cases here for different events
  }

  Stream<ArchivedReceiptsState> _getArchivedReceiptsMetaData(GetArchiveMetaData event) async* {
    yield GetArchiveDataLoading();

    var result = await _receiptRepository.getArchivedReceiptMetaData();

    if (result.success){
      yield GetArchiveMetaDataSuccessState(dataRange: result.obj);
    } else {
      yield GetArchiveMetaDataFailState(dataRange: result.obj);
    }
  }

  Stream<ArchivedReceiptsState> _handleGetArchivedReceipts(GetArchivedReceipts event) async* {
    yield GetArchiveDataLoading();

    var result = await _receiptRepository.getArchivedReceipts(event.yearMonth);

    if (result.success){
      yield GetArchivedReceiptsSuccessState(receipts: result.obj);
    } else {
      yield GetArchivedReceiptsFailState(receipts: []);
    }
  }

  Stream<ArchivedReceiptsState> _handleUnArchivedReceipt(UnArchivedReceipt event) async* {
    var result = await _receiptRepository.unArchiveReceipt(event.receiptId);

    if (result.success){
      yield UnArchivedReceiptSuccessState(receiptId: event.receiptId);
    } else {
      yield UnArchivedReceiptFailState(receiptId: event.receiptId);
    }
  }
}