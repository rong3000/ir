import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/user_repository.dart';

class EmailVerification extends StatefulWidget {
  final UserRepository _userRepository;
  final String name;
//  SearchBar({Key key, @required this.name, @required this.verified}) : super(key: key);

  EmailVerification({Key key, @required UserRepository userRepository, @required this.name})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  UserRepository get _userRepository => widget._userRepository;
  final TextEditingController _controller = new TextEditingController();

  String get name => widget.name;

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  Future<void> sendVerification() async {
    try {
      await _userRepository.currentUser.sendEmailVerification();
    } catch (e) {
      print("An error occured while trying to send email verification");
      print(e.message);
    }
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
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('email verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Column(children: <Widget>[
                AutoSizeText(
                  '${name} ${_userRepository.currentUser.isEmailVerified ? 'is verified' : 'is not verified'}',
                  style: TextStyle(fontSize: 16),
                  minFontSize: 6,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(height:25),
                _userRepository.currentUser.isEmailVerified ? Container(height:0):
                Container(
                  height: 25,
                  child: RaisedButton(
                    onPressed: (){
                      sendVerification();
                      _showMessage('Verification Email sent', "We have sent you the email verification again, please check if it's in the SPAM mail if it cannot be found in your inbox.");
                    },
                    child: AutoSizeText(
                      'Resend Verification',
                      style: TextStyle(fontSize: 12),
                      minFontSize: 6,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
