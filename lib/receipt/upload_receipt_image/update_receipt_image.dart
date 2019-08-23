import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import "package:rflutter_alert/rflutter_alert.dart";

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
  File _image = null;

  @override
  void initState() {
    super.initState();
  }

  Future<DataResult> _uploadReceipt() async {
    _image = await ImagePicker.pickImage(source: (widget._imageSource == IRImageSource.Gallary) ? ImageSource.gallery : ImageSource.camera);
//    File croppedFile = await ImageCropper.cropImage(
//      sourcePath: image.path,
//        ratioX: 1.0,
//        ratioY: 1.0,
//        maxWidth: 512,
//        maxHeight: 512);

    DataResult dataResult = await _userRepository.receiptRepository.uploadReceiptImage(_image);
    return dataResult;
  }

  void showAlert(String message, AlertType alertType) {
    Alert(
      context: context,
      type: alertType,
      title: "RFLUTTER ALERT",
      desc: message,
      buttons: [
        DialogButton(
          child: Text(
            "OK, Got it",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  Icon getIcon(AlertType alertType) {
    Color color = Colors.blue;
    IconData iconData = Icons.info;

    if (alertType == AlertType.error) {
      color = Colors.red;
      iconData = Icons.error;
    } else if (alertType == AlertType.warning) {
      color = Colors.orange;
      iconData = Icons.warning;
    }

    return new Icon(
      iconData,
      color: color,
      size: 80,
    );
  }

  Widget getErrorPage(String titleTxt, String message, {AlertType alertType : AlertType.info}) {
    return Scaffold(
        appBar: AppBar(title: Text(titleTxt)),
        body: Center (
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: new BoxDecoration(
              image: new DecorationImage(
                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
                image: new MemoryImage(_image.readAsBytesSync()),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                getIcon(alertType),
                Text(message,
                    style: TextStyle(
                        color: Colors.indigo,
                        //fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ]
            )
          )
        )
    );
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
                case ConnectionState.waiting:
                  return new Text('Submitting receipt, will be ready soon ...');
                default:
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else {
                    DataResult dataResult = snapshot.data;
                    if (dataResult.success) {
                      Receipt receipt = dataResult.obj as Receipt;
                      if (receipt == null || receipt.decodeStatus == DecodeStatusType.Unknown.index) {
                        // Show unknown error
                        return getErrorPage("Error", "We encounter an unknown error when submitting the receipt, please resubmit the receipt.");
                      } else if (receipt.decodeStatus == DecodeStatusType.ExtractTextFailed.index) {
                        // Show extracted text failure error
                        return getErrorPage("Extract Text Error", "Failed to extract the text from the image.");
                      } else if (receipt.decodeStatus == DecodeStatusType.MaybeNotValidReceipt.index) {
                        // Show image maybe not a valid receipt error
                        return getErrorPage("Invalid Receipt", "This maybe not a valid receipt, please double check.");
                      } else if (receipt.decodeStatus == DecodeStatusType.UnrecognizedFormat.index) {
                        // Show unrecognized format error
                        return getErrorPage("Recognizing", "The receipt has been submitted, we are now reconizing it, and will notify you after we recognize it.");
                      } else {
                        // Show add or update receipt page
                        return Text(receipt?.toString());
                      }
                    } else {
                      // Show error message
                      return getErrorPage("Error", "We encounter an error when submitting the receipt: " + dataResult.message);
                    }
                  }
              }
            },
          ),
        )
    );
  }
}