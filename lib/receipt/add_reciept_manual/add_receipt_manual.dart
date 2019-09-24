import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/category.dart';
import 'package:intelligent_receipt/data_model/currency.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';

class AddReceiptForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: pass this in from edit exisiting
    var receipt = Receipt();
    receipt.receiptDatetime = DateTime(2018, 10, 5);
    receipt.productName = 'Petrol';
    receipt.currencyCode = 'AUD';
    receipt.totalAmount = 120;
    receipt.categoryId = categoryList[0].id;
    receipt.companyName = 'Bobs shop';
    receipt.notes = 'Notes text';
    receipt.warrantyPeriod = 36;
    receipt.gstInclusive = true;
    return _AddReceiptFormState(receipt);
  }
}

class _AddReceiptFormState extends State<AddReceiptForm> {
  final _formKey = GlobalKey<FormState>();
  final pageTitleEdit = 'Edit Receipt';
  final pageTitleNew = 'Create Receipt';

  var isNew = true;
  Receipt receipt;
  Currency defaultCurrency;
  var gstInclusive = true;
  double warrantyPeriod = 0;
  var currenciesList = List<Currency>();
  var defaultCategoryValue = categoryList[0].id;
  UserRepository _userRepository;

  _AddReceiptFormState(this.receipt) {
    isNew = this.receipt == null;
    if (isNew) {
      this.receipt = Receipt();
    }
  }

  @override
  void initState() {
    _userRepository = RepositoryProvider.of<UserRepository>(context);
    defaultCurrency = _userRepository.settingRepository.getDefaultCurrency();
    super.initState();
  }

  void deleteReceipt() {
    // TODO handle delete/clear
  }

  void saveForm() {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();
      var x = 1;
    }
  }

  String textFieldValidator(value) {
    if (value.isEmpty) {
      return 'Value required';
    }
    return null;
  }

  List<DropdownMenuItem<String>> getCurrencyCodesList() {
    var list = List<DropdownMenuItem<String>>();
    currenciesList = _userRepository.settingRepository.getCurrencies();

    //Handle none returned
    if (currenciesList.length == 0) {
      currenciesList.add(defaultCurrency);
    }

    for (var currency in currenciesList) {
      list.add(DropdownMenuItem<String>(
          value: currency.code, child: Text(currency.code)));
    }

    return list;
  }

  List<DropdownMenuItem<int>> getCategorylist() {
    var list = List<DropdownMenuItem<int>>();
    for (var cat in categoryList) {
      list.add(
          DropdownMenuItem<int>(value: cat.id, child: Text(cat.categoryName)));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? pageTitleNew : pageTitleEdit),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              deleteReceipt();
            },
          ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              this.saveForm();
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                DateTimePickerFormField(
                  editable: false,
                  inputType: InputType.date,
                  initialDate: DateTime.now(),
                  format: DateFormat("yyyy-MM-dd"),
                  decoration: InputDecoration(labelText: 'Purchase Date'),
                  initialValue:
                      isNew ? DateTime.now() : receipt.receiptDatetime,
                  onSaved: (DateTime value) {
                    receipt.receiptDatetime = value;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 7,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Total Amount'),
                        initialValue:
                            isNew ? '0' : receipt.totalAmount.toString(),
                        validator: textFieldValidator,
                        onSaved: (String value) {
                          receipt.totalAmount = double.tryParse(value);
                        },
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Currency Code'),
                        items: getCurrencyCodesList(),
                        value: defaultCurrency.code,
                        onSaved: (String value) {
                          receipt.currencyCode = value;
                        },
                        onChanged: (String newValue) {
                          setState(() {
                            defaultCurrency = currenciesList
                                .singleWhere((curr) => curr.code == newValue);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                FormField<bool>(
                  builder: (formState) => CheckboxListTile(
                    title: const Text('GST Inclusive'),
                    value: isNew ?  gstInclusive: receipt.gstInclusive,
                    onChanged: (newValue) {
                      setState(() {
                        gstInclusive = !gstInclusive;
                      });
                    },
                  ),
                  onSaved: (newValue) {
                    receipt.gstInclusive = gstInclusive;
                  },
                ),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Category'),
                  items: getCategorylist(),
                  value: defaultCategoryValue,
                  onSaved: (int value) {
                    receipt.categoryId = value;
                  },
                  onChanged: (int newValue) {
                    setState(() {
                      defaultCategoryValue = newValue;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Shop/Vendor'),
                  initialValue: receipt.companyName,
                  validator: textFieldValidator,
                  onSaved: (String value) {
                    receipt.companyName = value;
                  },
                ),
                TextFormField(
                  initialValue: receipt.productName,
                  validator: textFieldValidator,
                  decoration: InputDecoration(labelText: 'Product Name'),
                  onSaved: (String value) {
                    receipt.productName = value;
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Warranty Period'),
                    ),
                    FormField<double>(
                      builder: (formFieldState) => Slider.adaptive(
                        value: isNew ? warrantyPeriod : receipt.warrantyPeriod,
                        divisions: warrantyPeriod < 24 ? 20 : 5,
                        min: 0,
                        max: 60,
                        label:
                            '${warrantyPeriod < 24 ? warrantyPeriod : warrantyPeriod / 12} ${warrantyPeriod < 24 ? "months" : "years"}',
                        onChanged: (newValue) {
                          setState(() {
                            warrantyPeriod = newValue;
                          });
                        },
                      ),
                      onSaved: (double newValue) {
                        receipt.warrantyPeriod = warrantyPeriod;
                      },
                    ),
                  ],
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Notes'),
                  initialValue: receipt.notes,
                  onSaved: (String value) {
                    receipt.notes = value;
                  },
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: .4,
                    child: Image.asset('assets/test.jpg',
                        fit: BoxFit
                            .cover), // TODO: load image from db or display 'no image selected'
                  ),
                ),
              ),
              Expanded(
                child: Icon(Icons.image),
                flex: 5,
              )
            ],
          )
        ]),
      ),
    );
  }
}
