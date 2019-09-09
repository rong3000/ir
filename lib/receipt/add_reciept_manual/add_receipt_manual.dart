import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddReceiptForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddReceiptFormState();
  }
}

class AddReceiptFormState extends State<AddReceiptForm> {
  
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Form(
          key: _formKey,
          child: TextFormField(
            initialValue: 'Hi',
            validator: (value) {
            if (value.isEmpty) {
              return 'Enter Text';
            }
            return null;
          }),
        ),
      ),
    );
  }
}
