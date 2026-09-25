import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String _message = '';
  String _phone = '';

  AuthState get state => _state;
  UserModel? get user => _user;
  String get message => _message;
  String get phone => _phone;
  bool get isAuthenticated => _state == AuthState.authenticated;

  void setPhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    _state = AuthState.loading;
    notifyListeners();

    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      try {
        final user = await _authService.getMe();
        if (user != null) {
          _setUser(user);
          _state = AuthState.authenticated;
          _saveFcmToken();
        } else {
          await _clearCachedUser();
          _state = AuthState.unauthenticated;
        }
      } catch (_) {
        // Offline or server unavailable: keep the session with the last known profile.
        final cached = await _cachedUser();
        _user = cached;
        _state = cached != null ? AuthState.authenticated : AuthState.unauthenticated;
      }
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Re-registers this device for push (e.g. right after the user grants notification permission).
  Future<void> registerPushToken() => _saveFcmToken();

  Future<void> _saveFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await ApiService().post('/auth/fcm-token', data: {'token': token});
      }
    } catch (_) {}
  }

  Future<bool> sendOtp(String phone, {String purpose = 'login'}) async {
    _state = AuthState.loading;
    notifyListeners();

    final result = await _authService.sendOtp(phone, purpose: purpose);
    _message = result.message;
    _state = result.success ? AuthState.initial : AuthState.error;
    notifyListeners();
    return result.success;
  }

  Future<bool> verifyOtpLogin(String phone, String otp) async {
    _state = AuthState.loading;
    notifyListeners();

    final result = await _authService.verifyOtpLogin(phone, otp);
    _message = result.message;
    if (result.success && result.user != null) {
      _setUser(result.user);
      _state = AuthState.authenticated;
      _saveFcmToken();
    } else {
      _state = AuthState.error;
    }
    notifyListeners();
    return result.success;
  }

  Future<bool> signup(String name, String phone, String otp, {String? email}) async {
    _state = AuthState.loading;
    notifyListeners();

    final result = await _authService.signup(name, phone, otp, email: email);
    _message = result.message;
    if (result.success && result.user != null) {
      _setUser(result.user);
      _state = AuthState.authenticated;
      _saveFcmToken();
    } else {
      _state = AuthState.error;
    }
    notifyListeners();
    return result.success;
  }

  void verifyPhoneFirebase(
    String phone, {
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String error) onFailed,
    Function(PhoneAuthCredential)? verificationCompleted,
  }) {
    _authService.verifyPhoneFirebase(
      phone,
      codeSent: codeSent,
      onFailed: onFailed,
      verificationCompleted: verificationCompleted,
    );
  }

  Future<bool> firebaseVerify(
    String verificationId,
    String smsCode, {
    String? name,
    String? email,
  }) async {
    _state = AuthState.loading;
    notifyListeners();
    final result = await _authService.firebaseVerify(verificationId, smsCode, name: name, email: email);
    _message = result.message;
    if (result.success && result.user != null) {
      _setUser(result.user);
      _state = AuthState.authenticated;
      _saveFcmToken();
    } else {
      _state = AuthState.error;
    }
    notifyListeners();
    return result.success;
  }

  Future<bool> forgotPassword(String phone) async {
    _state = AuthState.loading;
    notifyListeners();

    final result = await _authService.forgotPassword(phone);
    _message = result.message;
    _state = result.success ? AuthState.initial : AuthState.error;
    notifyListeners();
    return result.success;
  }

  Future<bool> resetPassword(String phone, String otp, String newPassword) async {
    _state = AuthState.loading;
    notifyListeners();

    final result = await _authService.resetPassword(phone, otp, newPassword);
    _message = result.message;
    _state = result.success ? AuthState.unauthenticated : AuthState.error;
    notifyListeners();
    return result.success;
  }

  Future<void> logout() async {
    await _authService.logout();
    await _clearCachedUser();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  static const _cacheKey = 'cached_user';

  void _setUser(UserModel? user) {
    _user = user;
    if (user == null) return;
    SharedPreferences.getInstance().then((p) => p.setString(_cacheKey, jsonEncode(user.toJson())));
  }

  Future<UserModel?> _cachedUser() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_cacheKey);
      return raw == null ? null : UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearCachedUser() async => (await SharedPreferences.getInstance()).remove(_cacheKey);

  void clearMessage() {
    _message = '';
    notifyListeners();
  }
}
