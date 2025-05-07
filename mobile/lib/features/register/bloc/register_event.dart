import 'package:equatable/equatable.dart';
import '../models/user_model_register.dart';



abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final User user;

  const RegisterSubmitted(this.user);

  @override
  List<Object> get props => [user];
}
