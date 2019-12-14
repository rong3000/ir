import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intelligent_receipt/data_model/category.dart';
import 'package:intelligent_receipt/data_model/currency.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/data_model/report_repository.dart';
import 'package:intelligent_receipt/helper_widgets/date_time_picker.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_bloc.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_event.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_state.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'dart:async';
import 'package:image_cropper/image_cropper.dart';
import '../../helper_widgets/zoomable_image.dart';

class AddEditReiptForm extends StatefulWidget {
  final Receipt _receiptItem;

  AddEditReiptForm(this._receiptItem);

  @override
  State<StatefulWidget> createState() {
    var isNew = _receiptItem == null;
    Receipt receipt;

    if (isNew) {
      receipt = Receipt()
        ..receiptDatetime = DateTime.now()
        ..receiptTypeId = 0
        ..productName = ""
        ..gstInclusive = true
        ..totalAmount = 0
        ..companyName = ""
        ..warrantyPeriod = 0
        ..notes = ""
        ..categoryId = 1;
    } else {
      receipt = _receiptItem;
    }
    if (receipt.gstInclusive == null) {
      receipt.gstInclusive = true;
    }

    return _AddEditReiptFormState(receipt, isNew);
  }
}

class _AddEditReiptFormState extends State<AddEditReiptForm> {
  final _formKey = GlobalKey<FormState>();
  String get pageTitleEdit => allTranslations.text('app.add-edit-manual-page.edit-title');
  String get pageTitleNew => allTranslations.text('app.add-edit-manual-page.new-title');

  var isNew;
  File receiptImageFile;
  Image receiptImage;
  Receipt receipt;
  Currency receiptCurrency;
  var currenciesList = List<Currency>();
  var categoryList = List<Category>();
  UserRepository _userRepository;
  ReceiptBloc _receiptBloc;
  ReceiptState _state;
  String get warrantyPeriodUnit => receipt.warrantyPeriod < 24 ? allTranslations.text('words.months') : allTranslations.text('words.years');

  _AddEditReiptFormState(this.receipt, this.isNew) {
    receiptCurrency = Currency();
    receiptCurrency.code = 'AUD';
    if ((this.receipt.categoryId == null) || (this.receipt.categoryId < 1)) {
      this.receipt.categoryId = 1;
    }

    if (!isNew && receipt.image != null && receipt.image.isNotEmpty) {
      var imageData = UriData.parse(receipt.image);
      var bytes = imageData.contentAsBytes();
      receiptImage = Image.memory(bytes);
    }
  }

  @override
  void initState() {
    _receiptBloc = BlocProvider.of<ReceiptBloc>(context);
    _userRepository = RepositoryProvider.of<UserRepository>(context);
    receiptCurrency = _userRepository.settingRepository.getCurrencyForCurrencyCode(receipt.currencyCode);
    if (receiptCurrency == null) {
      receiptCurrency = _userRepository.settingRepository.getDefaultCurrency() ?? receiptCurrency;
    }
    currenciesList = _userRepository.settingRepository.getCurrencies();
    categoryList = _userRepository.categoryRepository.categories;

    if (categoryList.length == 0) {
      _userRepository.categoryRepository
          .getCategoriesFromServer(forceRefresh: true)
          .then((value) {
        this.setState(() {
          categoryList = _userRepository.categoryRepository.categories;
          receipt.categoryId = categoryList[0].id;
        });
      });
    }

    if (currenciesList.length == 0) {
      _userRepository.settingRepository.getCurrenciesFromServer().then((value) {
        this.setState(() {
          currenciesList = _userRepository.settingRepository.getCurrencies();
          if (receiptCurrency == null) {
            receiptCurrency = _userRepository.settingRepository.getDefaultCurrency() ?? receiptCurrency;
          }
        });
      });
    }
    super.initState();
  }

  Future<void> _deleteReceipt() async {
    _receiptBloc.dispatch(ManualReceiptDelete(receipt: this.receipt));
  }

  void _saveForm() {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();
    } else {
      return;
    }

    //common save logic
    this.receipt.statusId = ReceiptStatusType.Reviewed.index;
    this.receipt.statusUpdateDatetime = DateTime.now();

    this.receipt.decodeStatus = DecodeStatusType.Success.index;
    this.receipt.receiptTypeId = 0;

    // if this is not null we have a new receipt OR have changed the existing image
    // either way send the base64 image to be saved/updated
    if (receiptImageFile != null) {
      this.receipt.imageFileExtension = this.receiptImageFile.path
          .substring(this.receiptImageFile.path.lastIndexOf('.') + 1)
          .trim();

      var imageStream = this.receiptImageFile?.readAsBytesSync();
      this.receipt.image = imageStream != null ? base64Encode(imageStream) : null;
    } else {
      // No update to image, set null so existing image is not re-sent to api for update
      this.receipt.image = null;
    }

    // new logic
    if (isNew) {
      this.receipt.uploadDatetime = DateTime.now();

      _receiptBloc.dispatch(ManualReceiptUpload(receipt: this.receipt));
    } else {
      _receiptBloc.dispatch(ManualReceiptUpdate(receipt: this.receipt));
    }
  }

  String textFieldValidator(value) {
    if (value.isEmpty) {
      return allTranslations.text('app.common.value-required-validation');
    }
    return null;
  }

  List<DropdownMenuItem<String>> _getCurrencyCodesList() {
    var list = List<DropdownMenuItem<String>>();

    //Handle none returned
    if (currenciesList.length > 0) {
      for (var currency in currenciesList) {
        list.add(DropdownMenuItem<String>(
            value: currency.code, child: Text(currency.code)));
      }
    }

    return list;
  }

  List<DropdownMenuItem<int>> _getCategorylist() {
    var list = List<DropdownMenuItem<int>>();
    for (var cat in categoryList) {
      list.add(
        DropdownMenuItem<int>(value: cat.id, child: Text(cat.categoryName)),
      );
    }
    if (!categoryList.any((c) => c.id == receipt.categoryId) && categoryList.length > 0){
      receipt.categoryId = categoryList[0].id;
    }
    return list;
  }

  Future<ImageSource> _getImageSource() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(allTranslations.text('app.select-image-source-dialog.title')),
          actions: <Widget>[
            FlatButton(
              child: Text(allTranslations.text('words.camera')),
              onPressed: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
            ),
            FlatButton(
              child: Text(allTranslations.text('words.gallery')),
              onPressed: () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  _selectImage() async {
    var source = await _getImageSource();
    if (source != null) {
      var ri = await ImagePicker.pickImage(source: source, maxWidth: 600);
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: ri.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: allTranslations.text('app.image-cropper.title'),
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      );
      if (croppedFile != null) {
        setState(() {
          receiptImageFile = croppedFile;
          receiptImage = Image.file(croppedFile);
        });
      }

    }
  }

  List<Widget> _getImageWidgets() {
    var widgets = List<Widget>();

    if (receiptImage != null) {
      widgets.add(
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: () {
              _showFullImage(receiptImage);
            },
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: .6,
                child: receiptImage,
              ),
            ),
          ),
        ),
      );
    }

    widgets.add(
      Expanded(
        flex: 5,
        child: GestureDetector(
            onTap: () {
              _selectImage();
            },
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.image,
                  size: 60,
                  semanticLabel: allTranslations.text('app.add-edit-manual-page.select-new-image-label'),
                ),
                Text(allTranslations.text('app.add-edit-manual-page.select-new-image-label'))
              ],
            )),
      ),
    );

    return widgets;
  }

  void _showMessage(String title, String message) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: new Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text(allTranslations.text('words.close')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future<void> _showFullImage(Image childImage) async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.8,
                child:
                childImage != null ?
                ZoomableImage(childImage.image, backgroundColor: Colors.white) :
                Center(child: Text(allTranslations.text('app.add-edit-manual-page.show-full-image-missing'), textAlign: TextAlign.center)),
              ),
              Container(
                height: 30,
                child: FlatButton(
                  child: Text(allTranslations.text('words.close')),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          );
        });
  }

  List<Widget> _getAppBarButtons() {
    List<Widget> buttons = new List<Widget>();
    if (!isNew) {
      buttons.add(IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          if (_state == null || !_state.uploadinProgress){
            _deleteReceipt();
          }
        },
      ));
    }

    buttons.add(IconButton(
      icon: const Icon(Icons.done),
      onPressed: () {
        if ( _state == null || !_state.uploadinProgress){
          this._saveForm();
        }
      },
    ));

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? pageTitleNew : pageTitleEdit),
        actions: _getAppBarButtons(),
      ),
      body: BlocListener(
        bloc: _receiptBloc,
        listener: (BuildContext context, ReceiptState state) {
          _state = state;        
          if (state.uploadFail) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(allTranslations.text('app.common.uploading-failed') + state.errorMessage), Icon(Icons.error)],
                  ),
                  backgroundColor: Colors.red,
                ),
              );
          }
          if (state.uploadinProgress) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(allTranslations.text('app.common.uploading-receipt-in-progess')),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
          }
          if (state.uploadSuccess) {
            Navigator.pop(context);
            _showMessage(
              allTranslations.text('app.upload-result-dialog.title'),  
              allTranslations.text('app.upload-result-dialog.success-message'),
              );
          }
          if (state.deleteSuccess) {
            Navigator.of(context).pop();
            _showMessage(
              allTranslations.text('app.delete-result-dialog.title'), 
              allTranslations.text('app.delete-result-dialog.success-message'),
              );
          }
          if (state.deleteInProgress) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(allTranslations.text('app.common.deleting-in-progress')),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
          }
          if (state.deleteFail) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(allTranslations.text('app.common.deleting-failed') + state.errorMessage), Icon(Icons.error)],
                  ),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        child: BlocBuilder(
          bloc: _receiptBloc,
          builder: (BuildContext context, ReceiptState state) {
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        IRDateTimePicker(
                          labelText: allTranslations.text('app.add-edit-manual-page.purchase-date-label'),
                          selectedDate: receipt.receiptDatetime.isBefore(DateTime(1970)) ? DateTime.now() : receipt.receiptDatetime,
                          selectDate: (newValue) {
                            setState(() {
                              receipt.receiptDatetime = newValue;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              flex: 7,
                              child: Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: TextFormField(
                                  decoration: InputDecoration(labelText: allTranslations.text('app.add-edit-manual-page.total-amount-label')),
                                  initialValue: receipt.totalAmount == 0 ? "0" : receipt.totalAmount.toString(),
                                  validator: textFieldValidator,
                                  onSaved: (String value) {
                                    receipt.totalAmount = double.tryParse(value);
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                decoration:
                                    InputDecoration(labelText: allTranslations.text('app.add-edit-manual-page.currency-code-label')),
                                items: _getCurrencyCodesList(),
                                value: (receiptCurrency!= null) ? receiptCurrency.code : "AUD",
                                onSaved: (String value) {
                                  receipt.currencyCode = value;
                                },
                                onChanged: (String newValue) {
                                  setState(() {
                                    receiptCurrency =
                                        currenciesList.singleWhere(
                                            (curr) => curr.code == newValue);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        FormField<bool>(
                          builder: (formState) => CheckboxListTile(
                            title: Text(allTranslations.text('app.add-edit-manual-page.gst-inclusive-label')),
                            value: receipt.gstInclusive ?? true,
                            onChanged: (newValue) {
                              setState(() {
                                receipt.gstInclusive = !receipt.gstInclusive;
                              });
                            },
                          ),
                          onSaved: (newValue) {
                            receipt.gstInclusive = receipt.gstInclusive;
                          },
                        ),
                        DropdownButtonFormField<int>(
                          decoration: InputDecoration(labelText: allTranslations.text('app.add-edit-manual-page.category-label')),
                          items: _getCategorylist(),
                          value: receipt.categoryId,
                          onSaved: (int value) {
                            receipt.categoryId = value;
                          },
                          onChanged: (int newValue) {
                            setState(() {
                              receipt.categoryId = newValue;
                            });
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: allTranslations.text('app.add-edit-manual-page.vendor-label')),
                          initialValue: receipt.companyName,
                          validator: textFieldValidator,
                          onSaved: (String value) {
                            receipt.companyName = value;
                          },
                        ),
                        TextFormField(
                          initialValue: receipt.productName,
                          decoration: InputDecoration(labelText: allTranslations.text('app.add-edit-manual-page.product-name-label')),
                          onSaved: (String value) {
                            receipt.productName = value;
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(allTranslations.text('app.add-edit-manual-page.warranty-period-label')),
                            ),
                            FormField<double>(
                              builder: (formFieldState) => Slider.adaptive(
                                value: receipt.warrantyPeriod,
                                divisions: receipt.warrantyPeriod < 24 ? 20 : 5,
                                min: 0,
                                max: 60,
                                label:
                                    '${receipt.warrantyPeriod < 24 ? receipt.warrantyPeriod : receipt.warrantyPeriod / 12} $warrantyPeriodUnit',
                                onChanged: (newValue) {
                                  setState(() {
                                    receipt.warrantyPeriod = newValue;
                                  });
                                },
                              ),
                              onSaved: (double newValue) {
                                receipt.warrantyPeriod = receipt.warrantyPeriod;
                              },
                            ),
                          ],
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: allTranslations.text('app.add-edit-manual-page.notes-label')),
                          initialValue: receipt.notes,
                          onSaved: (String value) {
                            receipt.notes = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(children: _getImageWidgets()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
