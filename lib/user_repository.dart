import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/data_model/category_repository.dart';
import 'package:intelligent_receipt/data_model/report_repository.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookLogin _facebookLogin;

  ReceiptRepository receiptRepository;
  CategoryRepository categoryRepository;
  SettingRepository settingRepository;
  ReportRepository reportRepository;

  String userGuid;
  int userId = 1; // The id stored in our service database

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin, FacebookLogin facebookLogin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn(),
        _facebookLogin = facebookLogin ?? FacebookLogin()		{
     receiptRepository = new ReceiptRepository(this);
     categoryRepository = new CategoryRepository(this);
     settingRepository = new SettingRepository(this);
     reportRepository = new ReportRepository(this);
     postSignIn(null); // xxx temporary put the code here
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
    FirebaseUser currentUser = await _firebaseAuth.currentUser();
    userGuid = currentUser?.uid;
    return currentUser;
  }

Future<FirebaseUser> signInWithFacebook() async {
    final FacebookLoginResult result =
        await _facebookLogin.logIn(['email']);
		
		final AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
		
    
    await _firebaseAuth.signInWithCredential(credential);
    FirebaseUser currentUser = await _firebaseAuth.currentUser();
    userGuid = currentUser?.uid;
    return currentUser;
}

  Future<void> signInWithCredentials(String email, String password) async {
    FirebaseUser currentUser = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    userGuid = currentUser?.uid;
  }

  Future<void> signUp({String email, String password}) async {
    FirebaseUser currentUser =  await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    userGuid = currentUser?.uid;
  }

  Future<void> signOut() async {
    userGuid = "";
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
	  _facebookLogin.logOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    userGuid = currentUser?.uid;
    return currentUser != null;
  }

  Future<String> getUser() async {
    return (await _firebaseAuth.currentUser()).email;
  }

  Future<String> getUID() async {
    FirebaseUser currentUser = await _firebaseAuth.currentUser();
    userGuid = currentUser?.uid;
    return userGuid;
  }

  Future<void> postSignIn(FirebaseUser currentUser) async {
    // Get user ID from server
    userId = 1;
    receiptRepository.getReceiptsFromServer(forceRefresh: true);
    categoryRepository.getCategoriesFromServer(forceRefresh: true);
    settingRepository.getCurrenciesFromServer();
    settingRepository.getSettingsFromServer();
    reportRepository.getReportsFromServer(forceRefresh: true);
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
