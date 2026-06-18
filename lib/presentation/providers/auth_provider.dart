import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/auth/auth_usecases.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool emailSent;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.emailSent = false,
  });

  AuthState copyWith({bool? isLoading, String? error, bool? isAuthenticated, bool? emailSent}) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        emailSent: emailSent ?? this.emailSent,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final ForgotPasswordUseCase _forgotPassword;
  final LogoutUseCase _logout;

  AuthNotifier(this._login, this._register, this._forgotPassword, this._logout)
      : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _login(email, password);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _register(email, password);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      await _forgotPassword(email);
      state = state.copyWith(isLoading: false, emailSent: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    await _logout();
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(error: null);

  void resetEmailSent() => state = state.copyWith(emailSent: false);
}
