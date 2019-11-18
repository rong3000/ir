import 'package:intelligent_receipt/user_repository.dart';

abstract class IRRepository {
  UserRepository userRepository;

  IRRepository(this.userRepository);

  Future<String> getToken() async {
    return await userRepository.currentUser.getIdToken();
  }
}
