import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  AuthResult({required this.success, required this.message, this.user});
}

class AuthService {
  final _api = ApiService();

  Future<AuthResult> sendOtp(String phone, {String purpose = 'login'}) async {
    try {
      final res = await _api.post('/auth/send-otp', data: {'phone': phone, 'purpose': purpose});
      return AuthResult(success: true, message: res.data['message']);
    } on DioException catch (e) {
      return AuthResult(success: false, message: e.response?.data['message'] ?? 'Failed to send OTP');
    }
  }

  Future<AuthResult> verifyOtpLogin(String phone, String otp) async {
    try {
      final res = await _api.post('/auth/verify-otp', data: {'phone': phone, 'otp': otp});
      final data = res.data['data'];
      await _api.saveTokens(data['accessToken'], data['refreshToken']);
      return AuthResult(
        success: true,
        message: res.data['message'],
        user: UserModel.fromJson(data['user']),
      );
    } on DioException catch (e) {
      return AuthResult(success: false, message: e.response?.data['message'] ?? 'OTP verification failed');
    }
  }

  Future<AuthResult> signup(String name, String phone, String otp, {String? email}) async {
    try {
      final res = await _api.post('/auth/signup', data: {
        'name': name,
        'phone': phone,
        'otp': otp,
        if (email != null && email.isNotEmpty) 'email': email,
      });
      final data = res.data['data'];
      await _api.saveTokens(data['accessToken'], data['refreshToken']);
      return AuthResult(
        success: true,
        message: res.data['message'],
        user: UserModel.fromJson(data['user']),
      );
    } on DioException catch (e) {
      return AuthResult(success: false, message: e.response?.data['message'] ?? 'Signup failed');
    }
  }

  Future<AuthResult> forgotPassword(String phone) async {
    try {
      final res = await _api.post('/auth/forgot-password', data: {'phone': phone});
      return AuthResult(success: true, message: res.data['message']);
    } on DioException catch (e) {
      return AuthResult(success: false, message: e.response?.data['message'] ?? 'Failed');
    }
  }

  Future<AuthResult> resetPassword(String phone, String otp, String newPassword) async {
    try {
      final res = await _api.post('/auth/reset-password', data: {
        'phone': phone,
        'otp': otp,
        'newPassword': newPassword,
      });
      return AuthResult(success: true, message: res.data['message']);
    } on DioException catch (e) {
      return AuthResult(success: false, message: e.response?.data['message'] ?? 'Reset failed');
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final res = await _api.get('/auth/me');
      return UserModel.fromJson(res.data['data']['user']);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _api.logout();
  }

  Future<bool> isLoggedIn() => _api.isLoggedIn();
}
