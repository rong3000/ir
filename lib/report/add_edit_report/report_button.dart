import 'package:flutter/material.dart';

class ReportButton extends StatelessWidget {
  final VoidCallback _onPressed;
  final String _buttonName;

  ReportButton({Key key, VoidCallback onPressed, String buttonName})
      : _onPressed = onPressed,
        _buttonName = buttonName,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: _onPressed,
        child: Text('${_buttonName}'),
      ),
    );
  }
}
