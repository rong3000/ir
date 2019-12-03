import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:intelligent_receipt/data_model/preferences/preferences_repository.dart';
import 'package:intelligent_receipt/data_model/user.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/data_model/category_repository.dart';
import 'package:intelligent_receipt/data_model/report_repository.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';

import 'data_model/webservice.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookLogin _facebookLogin;

  ReceiptRepository receiptRepository;
  CategoryRepository categoryRepository;
  SettingRepository settingRepository;
  ReportRepository reportRepository;
  PreferencesRepository preferencesRepository;


  FirebaseUser currentUser;
  String userGuid;

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin, FacebookLogin facebookLogin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn(),
        _facebookLogin = facebookLogin ?? FacebookLogin()		{
     receiptRepository = new ReceiptRepository(this);
     categoryRepository = new CategoryRepository(this);
     settingRepository = new SettingRepository(this);
     reportRepository = new ReportRepository(this);
     preferencesRepository = new PreferencesRepository();
  }

  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);
    currentUser = await _firebaseAuth.currentUser();
    userGuid = currentUser?.uid;
    postSignIn();
    return currentUser;
  }

Future<FirebaseUser> signInWithFacebook() async {
    final FacebookLoginResult result =
        await _facebookLogin.logIn(['email']);
		
		final AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
		
    
    await _firebaseAuth.signInWithCredential(credential);
    currentUser = await _firebaseAuth.currentUser();
    userGuid = currentUser?.uid;
    postSignIn();
    return currentUser;
}

  Future<void> signInWithCredentials(String email, String password) async {
    currentUser = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    userGuid = currentUser?.uid;
    postSignIn();
  }

  Future<void> signUp({String email, String password}) async {
    currentUser =  await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    userGuid = currentUser?.uid;
    postSignIn();
  }

  Future<void> signOut() async {
    currentUser = null;
    userGuid = null;
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
	  _facebookLogin.logOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    currentUser = await _firebaseAuth.currentUser();
    userGuid = currentUser?.uid;
    return currentUser != null;
  }

  Future<String> getUser() async {
    return ((await _firebaseAuth.currentUser()).displayName != null) ? (await _firebaseAuth.currentUser()).displayName : (await _firebaseAuth.currentUser()).email;
  }

  Future<String> getUID() async {
    FirebaseUser currentUser = await _firebaseAuth.currentUser();
    userGuid = currentUser?.uid;
    return userGuid;
  }

  Future<User> registerNewUser() async { // Maybe not needed
    User newUser = User();
    newUser.firstname = currentUser.displayName;
    newUser.email = currentUser.email;
    newUser.mobile = currentUser.phoneNumber;
    var result = await webservicePost(Urls.CreateNewUser, await currentUser.getIdToken(), jsonEncode(newUser));
    if (result.success){
      return result.obj as User;
    }
    return null;
  }

  Future<void> postSignIn() async {
    if (currentUser != null) {
      receiptRepository.getReceiptsFromServer(forceRefresh: true);
      categoryRepository.getCategoriesFromServer(forceRefresh: true);
      settingRepository.getCurrenciesFromServer();
      settingRepository.getSettingsFromServer();
      reportRepository.getReportsFromServer(forceRefresh: true);
    }
    /*
    // Get receipts from server;

    await receiptRepository.getReceiptsFromServer(forceRefresh: true);

    // Some testing code
    if (receiptRepository.receipts.length > 0) {
      DataResult dataResult = await receiptRepository.getReceipt(receiptRepository.receipts[0].id);
      Receipt receipt = dataResult.obj as Receipt;
      receipt.decodedContent = "888";
      receipt.extractedContent = "999";

      dataResult = await receiptRepository.updateReceipt(receipt);

      List<int> receiptIds = new List<int>();
      receiptIds.add(receiptRepository.receipts[0].id);
      await receiptRepository.deleteReceipts(receiptIds);
    }

    // Test categories
    DataResult addCategoryResult = await categoryRepository.addCategory("Labor");
    Category category = addCategoryResult.obj as Category;
    category.categoryName = "Rent";
    DataResult updateCategoryResult = await categoryRepository.updateCategory(category);
    await categoryRepository.deleteCategory(category.id);

    // Test Settings
    List<Currency> currencies = settingRepository.getCurrencies();
    Currency defaultCurrency = await settingRepository.getDefaultCurrency();
    DataResult setDefaultCurrency = await settingRepository.setDefaultCurrency(5);
    */
  }
}
