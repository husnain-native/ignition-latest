import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userData;
  User? _user;
  AuthStatus _status = AuthStatus.initial;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userData => _userData;
  User? get user => _user;
  AuthStatus get status => _status;

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _error = null;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final credential = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      _user = credential.user;
      _userData = await _authService.getCurrentUserData();
      _isLoading = false;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );
      _user = credential.user;
      _userData = await _authService.getCurrentUserData();
      _isLoading = false;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _userData = null;
      _user = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isUserLoggedIn();
      if (isLoggedIn) {
        _user = FirebaseAuth.instance.currentUser;
        _userData = await _authService.getCurrentUserData();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
