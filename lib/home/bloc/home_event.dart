import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeEvent extends Equatable {
  HomeEvent([List props = const []]) : super(props);
}

class EmailChanged extends HomeEvent {
  final String email;

  EmailChanged({@required this.email}) : super([email]);

  @override
  String toString() => 'EmailChanged { email :$email }';
}

class PasswordChanged extends HomeEvent {
  final String password;

  PasswordChanged({@required this.password}) : super([password]);

  @override
  String toString() => 'PasswordChanged { password: $password }';
}

class Submitted extends HomeEvent {
  final String email;
  final String password;

  Submitted({@required this.email, @required this.password})
      : super([email, password]);

  @override
  String toString() {
    return 'Submitted { email: $email, password: $password }';
  }
}
