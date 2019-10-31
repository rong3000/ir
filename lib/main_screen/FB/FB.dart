import 'dart:async';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'DetailedScreen.dart'; //important fix

//void main() => runApp(new FB());

class FB extends StatefulWidget {
  @override
  _FBState createState() => new _FBState();
}

class _FBState extends State<FB> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  //my code
  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  //end my code

  Future<FirebaseUser> _signIn(BuildContext context) async {
    Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text('Sign in button clicked'),
        ));

    final FacebookLoginResult result =
        await facebookSignIn.logIn(['email']);

    FirebaseUser user =
        await _fAuth.signInWithCustomToken(token: result.accessToken.token);
    //Token: ${accessToken.token}

    ProviderDetails userInfo = new ProviderDetails(
        user.providerId, user.uid, user.displayName, user.photoUrl, user.email);

    List<ProviderDetails> providerData = new List<ProviderDetails>();
    providerData.add(userInfo);

    UserInfoDetails userInfoDetails = new UserInfoDetails(
        user.providerId,
        user.uid,
        user.displayName,
        user.photoUrl,
        user.email,
        user.isAnonymous,
        user.isEmailVerified,
        providerData);

    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new DetailedScreen(detailsUser: userInfoDetails),
      ),
    );

    return user;
  }

  Future<Null> _signOut(BuildContext context) async {
    await facebookSignIn.logOut();
    Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text('Sign out button clicked'),
        ));
    print('Signed out');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Fb Sign In with Firebase'),
      ),
      body: new Builder(
        builder: (BuildContext context) {
          return new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new MaterialButton(
                  //padding: new EdgeInsets.all(16.0),
                  minWidth: 150.0,
                  onPressed: () => _signIn(context)
                      .then((FirebaseUser user) => print(user))
                      .catchError((e) => print(e)),
                  child: new Text('Sign in with Facebook'),
                  color: Colors.lightBlueAccent,
                ),
                new Padding(
                  padding: const EdgeInsets.all(5.0),
                ),
                new MaterialButton(
                  minWidth: 150.0,
                  onPressed: () => _signOut(context),
                  child: new Text('Sign Out'),
                  color: Colors.lightBlueAccent,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class UserInfoDetails {
  UserInfoDetails(this.providerId, this.uid, this.displayName, this.photoUrl,
      this.email, this.isAnonymous, this.isEmailVerified, this.providerData);

  /// The provider identifier.
  final String providerId;

  /// The provider’s user ID for the user.
  final String uid;

  /// The name of the user.
  final String displayName;

  /// The URL of the user’s profile photo.
  final String photoUrl;

  /// The user’s email address.
  final String email;

  // Check anonymous
  final bool isAnonymous;

  //Check if email is verified
  final bool isEmailVerified;

  //Provider Data
  final List<ProviderDetails> providerData;
}

class ProviderDetails {
  final String providerId;

  final String uid;

  final String displayName;

  final String photoUrl;

  final String email;

  ProviderDetails(
      this.providerId, this.uid, this.displayName, this.photoUrl, this.email);
}
