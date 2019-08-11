import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/data_model/category_repository.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  ReceiptRepository receiptRepository;
  CategoryRepository categoryRepository;

  String userGuid;
  int userId = 1; // The id stored in our service database

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn() {
     receiptRepository = new ReceiptRepository(this);
     categoryRepository = new CategoryRepository(this);
     // postSignIn(null); // xxx temporary put the code here
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

    // Get receipts from server
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
  }
}
