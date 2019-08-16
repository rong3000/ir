import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';


class UploadReceiptImage extends StatefulWidget {
  final UserRepository _userRepository;
  final IRImageSource _imageSource;
  UploadReceiptImage({
    Key key,
    @required UserRepository userRepository,
    @required IRImageSource imageSource
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _imageSource = imageSource,
        super(key: key) {}

  @override
  UploadReceiptImageState createState() => UploadReceiptImageState();
}

class UploadReceiptImageState extends State<UploadReceiptImage> {

  UserRepository get _userRepository => widget._userRepository;

  @override
  void initState() {
    super.initState();
  }

  Future<DataResult> _uploadReceipt() async {
    File image = await ImagePicker.pickImage(source: (widget._imageSource == IRImageSource.Gallary) ? ImageSource.gallery : ImageSource.camera);
//    File croppedFile = await ImageCropper.cropImage(
//      sourcePath: image.path,
//        ratioX: 1.0,
//        ratioY: 1.0,
//        maxWidth: 512,
//        maxHeight: 512);

    DataResult dataResult = await _userRepository.receiptRepository.uploadReceiptImage(image);
    return dataResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        body: new Center (
          child: new FutureBuilder<DataResult>(
            future: _uploadReceipt(), // a Future<String> or null
            builder: (BuildContext context, AsyncSnapshot<DataResult> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none: return new Text('Press button to start');
                case ConnectionState.waiting: return new Text('Awaiting result...');
                default:
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else {
                    DataResult dataResult = snapshot.data;
                    if (dataResult.success) {
                      Receipt receipt = dataResult.obj as Receipt;
                      if (receipt == null || receipt.decodeStatus == DecodeStatusType.Unknown.index) {
                        // Show unknown error

                      } else if (receipt.decodeStatus == DecodeStatusType.ExtractTextFailed.index) {
                        // Show extracted text failure error

                      } else if (receipt.decodeStatus == DecodeStatusType.MaybeNotValidReceipt.index) {
                        // Show image maybe not a valid receipt error

                      } else if (receipt.decodeStatus == DecodeStatusType.UnrecognizedFormat.index) {
                        // Show unrecognized format error

                      } else {
                        // Show add or update receipt page
                      }

                      // Return receipt editor form
                      return Text(receipt?.toString());
                    } else {
                      // Show error message
                      return Text('Error: ' + dataResult.message);
                    }
                  }
              }
            },
          ),
        )
    );
  }
}