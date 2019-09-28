import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/category.dart';
import 'package:intelligent_receipt/data_model/currency.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';

class AddEditReiptForm extends StatefulWidget {
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
    return _AddEditReiptFormState(null);
  }
}

class _AddEditReiptFormState extends State<AddEditReiptForm> {
  final _formKey = GlobalKey<FormState>();
  final pageTitleEdit = 'Edit Receipt';
  final pageTitleNew = 'Create Receipt';

  var isNew = true;
  Receipt receipt;
  Currency defaultCurrency;
  var currenciesList = List<Currency>();
  UserRepository _userRepository;

  _AddEditReiptFormState(this.receipt) {
    isNew = this.receipt == null;
    if (isNew) {
      this.receipt = Receipt();
      receipt.receiptDatetime = DateTime.now();
      receipt.totalAmount = 0;
      receipt.categoryId = categoryList[2].id;
      receipt.warrantyPeriod = 0;
      receipt.gstInclusive = true;
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
    }
    // TODO: Dispatch save action
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
                  initialValue: receipt.receiptDatetime,
                  onSaved: (DateTime value) {
                    receipt.receiptDatetime = value;
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
                          decoration:
                              InputDecoration(labelText: 'Total Amount'),
                          initialValue: receipt.totalAmount.toString(),
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
                    value: receipt.gstInclusive,
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
                  decoration: InputDecoration(labelText: 'Category'),
                  items: getCategorylist(),
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
                        value: receipt.warrantyPeriod,
                        divisions: receipt.warrantyPeriod < 24 ? 20 : 5,
                        min: 0,
                        max: 60,
                        label:
                            '${receipt.warrantyPeriod < 24 ? receipt.warrantyPeriod : receipt.warrantyPeriod / 12} ${receipt.warrantyPeriod < 24 ? "months" : "years"}',
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
