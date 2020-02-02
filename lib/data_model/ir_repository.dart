import 'package:firebase_auth/firebase_auth.dart';
import 'package:intelligent_receipt/user_repository.dart';

abstract class IRRepository {
  UserRepository userRepository;

  IRRepository(this.userRepository);

  Future<String> getToken() async {
    IdTokenResult tokenResult = await userRepository.currentUser.getIdToken();
    return tokenResult.token;
  }
}
