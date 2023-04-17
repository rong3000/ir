import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class ShowPolicyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        allTranslations.text('app.login-screen.show-privacy-label'),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return ShowPrivacyPolicy();
          }),
        );
      },
    );
  }
}

class ShowPrivacyPolicy extends StatefulWidget {
  @override
  _ShowPrivacyPolicyState createState() => _ShowPrivacyPolicyState();
}

class _ShowPrivacyPolicyState extends State<ShowPrivacyPolicy> {
  final String url = 'assets/privacy_policy.html';
  String privacyPolicyHtml = '';

  @override
  void initState() {
    super.initState();
    loadPrivacyPolicyHtml();
  }

  Future<void> loadPrivacyPolicyHtml() async {
    String htmlString = await rootBundle.loadString(url);
    setState(() {
      privacyPolicyHtml = htmlString;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: privacyPolicyHtml.isEmpty
          ? Center(child: CircularProgressIndicator())
          : WebView(
        initialUrl: Uri.dataFromString(
          privacyPolicyHtml,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ).toString(),
      ),
    );
  }
}

