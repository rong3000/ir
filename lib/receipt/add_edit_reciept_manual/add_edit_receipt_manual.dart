import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intelligent_receipt/data_model/category.dart';
import 'package:intelligent_receipt/data_model/currency.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/data_model/report_repository.dart';
import 'package:intelligent_receipt/helper_widgets/date_time_picker.dart';
import 'package:intelligent_receipt/main_screen/main_screen.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_bloc.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_event.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_state.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'dart:async';
import 'package:image_cropper/image_cropper.dart';
import '../../helper_widgets/zoomable_image.dart';
import 'package:intelligent_receipt/data_model/exception_handlers/unsupported_version.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';
import 'package:intelligent_receipt/data_model/GeneralUtility.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AddEditReiptForm extends StatefulWidget {
  final Receipt _receiptItem;
  bool _disableSave = false;

  AddEditReiptForm(this._receiptItem, {bool disableSave: false}) {
    _disableSave = disableSave;
  }

  @override
  State<StatefulWidget> createState() {
    Receipt receipt = (_receiptItem == null) ? new Receipt() : _receiptItem;

    if (receipt.taxInclusive == null) {
      receipt.taxInclusive = true;
    }

    var isNew = (receipt.id == 0);
    return _AddEditReiptFormState(receipt, isNew);
  }
}

class _AddEditReiptFormState extends State<AddEditReiptForm> {
  final _formKey = GlobalKey<FormState>();
  String get pageTitleEdit => allTranslations.text('app.add-edit-manual-page.edit-title');
  String get pageTitleNew => allTranslations.text('app.add-edit-manual-page.new-title');
  final TextEditingController _taxAmountController = new TextEditingController();

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

    if (!isNew && receipt.imagePath != null && receipt.imagePath.isNotEmpty) {
      receiptImage = null;
      _userRepository.receiptRepository.getNetworkImage(Urls.GetImage + "/" + Uri.encodeComponent(receipt.imagePath)).then((image) {
        setState(() {
          receiptImage = image;
        });
      });
    }

    if (categoryList.length == 0) {
      _userRepository.categoryRepository
          .getCategoriesFromServer(forceRefresh: true)
          .then((value) {
        this.setState(() {
          categoryList = _userRepository.categoryRepository.categories;
          if (categoryList.length > 0) {
            receipt.categoryName = categoryList[0].categoryName;
          }
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

    if (isNew) {
      this.receipt.taxInclusive = _userRepository.settingRepository.isTaxInclusive();
    }
    _taxAmountController.text = receipt.taxAmount.toString();
    super.initState();
  }

  @override
  void dispose() {
    if (receiptImageFile != null) {
      receiptImageFile.delete();
    }
    _taxAmountController.dispose();
    super.dispose();
  }

  double roundDouble(double val, int places){
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  void _calcTaxAmount(Receipt receipt) {
    double taxPercentage = _userRepository.settingRepository.getTaxPercentage();
    if (receipt.taxInclusive) {
      receipt.taxAmount = roundDouble(receipt.totalAmount * taxPercentage / (100 + taxPercentage), 2);
    } else {
      receipt.taxAmount = roundDouble(receipt.totalAmount * taxPercentage / 100, 2);
    }
    _taxAmountController.text = receipt.taxAmount.toString();
    print(receipt.taxAmount);
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
    this.receipt.taxAmount = double.tryParse(_taxAmountController.text);

    // Update receipt date time if it is invalid
    _getReceiptDateTime(this.receipt);

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

  List<DropdownMenuItem<String>> _getCategorylist() {
    var list = List<DropdownMenuItem<String>>();
    for (var cat in categoryList) {
      list.add(
        DropdownMenuItem<String>(value: cat.categoryName, child: Text(cat.categoryName)),
      );
    }
    if (!categoryList.any((c) => c.categoryName == receipt.categoryName) && categoryList.length > 0){
      receipt.categoryName = categoryList[0].categoryName;
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
      File ri = await ImagePicker.pickImage(source: source);
      File compressedFile = await compressImage(ri);

      File croppedFile = await ImageCropper.cropImage(
        sourcePath: compressedFile.path,
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
      print("Cropped file size: " + croppedFile.lengthSync().toString());
      if (croppedFile != null) {
        setState(() {
          receiptImageFile = croppedFile;
          receiptImage = Image.file(croppedFile);
        });
      }
      compressedFile.delete();
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

    if (!widget._disableSave) {
      buttons.add(IconButton(
        icon: const Icon(Icons.done),
        onPressed: () {
          if ( _state == null || !_state.uploadinProgress){
            this._saveForm();
          }
        },
      ));
    }

    return buttons;
  }

  DateTime _getReceiptDateTime(Receipt receipt) {
    if (receipt.receiptDatetime.isBefore(DateTime(1900))) {
      receipt.receiptDatetime = (receipt.uploadDatetime != null ? receipt.uploadDatetime : DateTime.now());
    }

    return receipt.receiptDatetime;
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
            BlocProvider.of<MainScreenBloc>(context).dispatch(
                GoToPageEvent(this.receipt.receiptTypeId == SaleExpenseType.Expense.index ? MainScreenPages.expenses.index : MainScreenPages.expenses.index, ReceiptsSubPages.reviewed.index));
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
          if (state.versionNotSupported) {
            showUnsupportedVersionAlert(context);
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
                          selectedDate: _getReceiptDateTime(receipt),
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
                              flex: 6,
                              child: Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: TextFormField(
                                  decoration: InputDecoration(labelText:
                                    receipt.totalAmount == 0 ? allTranslations.text('app.add-edit-manual-page.enter-total-amount-label') : allTranslations.text('app.add-edit-manual-page.total-amount-label')),
                                  initialValue: receipt.totalAmount == 0 ? "" : receipt.totalAmount.toString(),
                                  validator: textFieldValidator,
                                  onChanged: (String value) {
                                    receipt.totalAmount = value.isNotEmpty ? double.tryParse(value) : 0;
                                    _calcTaxAmount(receipt);
                                  },
                                  onSaved: (String value) {
                                    receipt.totalAmount = double.tryParse(value);
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 4,
                              child: DropdownButtonFormField<String>(
                                isDense: true,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              flex: 4,
                              child: Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: TextFormField(
                                  controller: _taxAmountController,
                                  decoration: InputDecoration(labelText: allTranslations.text('app.add-edit-manual-page.tax-amount-label')),
                                  validator: (String value) {
                                    double taxAmount = double.tryParse(value);
                                    if (taxAmount < 0 || taxAmount > receipt.totalAmount) {
                                      return allTranslations.text('app.add-edit-manual-page.invalid-tax-amount');
                                    }
                                    return null;
                                  },
                                  onSaved: (String value) {
                                    receipt.taxAmount = double.tryParse(value);
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 6,
                              child: FormField<bool>(
                                builder: (formState) => CheckboxListTile(
                                  title: Text(allTranslations.text('app.add-edit-manual-page.gst-inclusive-label')),
                                  value: receipt.taxInclusive ?? true,
                                  onChanged: (newValue) {
                                    setState(() {
                                      receipt.taxInclusive = !receipt.taxInclusive;
                                      _calcTaxAmount(receipt);
                                    });
                                  },
                                ),
                                onSaved: (newValue) {
                                  receipt.taxInclusive = receipt.taxInclusive;
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              flex: 5,
                              child: Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: TextFormField(
                                  initialValue: receipt.percentageOnWork.toString(),
                                  decoration: InputDecoration(labelText: allTranslations.text('app.add-edit-manual-page.percentage-on-work-label')),
                                  validator: (String value) {
                                    double taxAmount = double.tryParse(value);
                                    if (taxAmount < 0 || taxAmount > 100) {
                                      return allTranslations.text('app.add-edit-manual-page.invalid-percentage-on-work');
                                    }
                                    return null;
                                  },
                                  onSaved: (String value) {
                                    receipt.percentageOnWork = double.tryParse(value);
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 5,
                              child: AutoSizeText(
                                allTranslations.text('app.add-edit-manual-page.percentage-on-work-description'),
                                style: TextStyle(fontSize: 12)
                                    .copyWith(color: Colors.black54)
                                    .apply(fontSizeFactor: 0.85),
                                minFontSize: 6,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              )
                            ),
                          ],
                        ),
                        DropdownButtonFormField<String>(
                          isDense: true,
                          decoration: InputDecoration(labelText: allTranslations.text('app.add-edit-manual-page.category-label')),
                          items: _getCategorylist(),
                          value: receipt.categoryName,
                          onSaved: (String value) {
                            receipt.categoryName = value;
                          },
                          onChanged: (String newValue) {
                            setState(() {
                              receipt.categoryName = newValue;
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
