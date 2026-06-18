import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repo;
  LoginUseCase(this._repo);
  Future<User> call(String email, String password) => _repo.login(email, password);
}

class RegisterUseCase {
  final AuthRepository _repo;
  RegisterUseCase(this._repo);
  Future<User> call(String email, String password) => _repo.register(email, password);
}

class ForgotPasswordUseCase {
  final AuthRepository _repo;
  ForgotPasswordUseCase(this._repo);
  Future<void> call(String email) => _repo.forgotPassword(email);
}

class LogoutUseCase {
  final AuthRepository _repo;
  LogoutUseCase(this._repo);
  Future<void> call() => _repo.logout();
}
