import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child:
      Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Image.asset('assets/ir_logo.png', height: 200),
      ),),
    );
  }
}
