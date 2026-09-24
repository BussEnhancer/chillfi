import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;
  final bool isNewUser;

  AuthResult({required this.success, required this.message, this.user, this.isNewUser = false});
}

class AuthService {
  final _api = ApiService();

  // ─── Send OTP (always via backend — backend handles Firebase/SMS delivery) ──

  Future<AuthResult> sendOtp(String phone, {String purpose = 'login'}) async {
    try {
      final res = await _api.post('/auth/send-otp', data: {'phone': phone, 'purpose': purpose});
      return AuthResult(success: true, message: res.data['message'] ?? 'OTP sent');
    } on DioException catch (e) {
      return AuthResult(success: false, message: e.response?.data['message'] ?? 'Failed to send OTP');
    }
  }

  // ─── Verify OTP & Login ──────────────────────────────────────────────────

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

  // ─── Signup (backend OTP flow only) ──────────────────────────────────────

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

  // ─── Firebase Phone Auth (client-side — no reCAPTCHA on mobile) ─────────

  void verifyPhoneFirebase(
    String phone, {
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String error) onFailed,
    Function(PhoneAuthCredential)? verificationCompleted,
  }) {
    try {
      FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        verificationCompleted: verificationCompleted ?? (_) {},
        verificationFailed: (e) => onFailed(e.message ?? 'Verification failed'),
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (_) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onFailed(e.toString());
    }
  }

  Future<AuthResult> firebaseVerify(
    String verificationId,
    String smsCode, {
    String? name,
    String? email,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user!.getIdToken();
      final res = await _api.post('/auth/firebase-verify', data: {
        'idToken': idToken,
        if (name != null && name.isNotEmpty) 'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
      });
      final data = res.data['data'];
      await _api.saveTokens(data['accessToken'], data['refreshToken']);
      return AuthResult(
        success: true,
        message: res.data['message'],
        user: UserModel.fromJson(data['user']),
        isNewUser: data['isNewUser'] ?? false,
      );
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'invalid-verification-code'
          ? 'Incorrect OTP. Please try again.'
          : e.code == 'session-expired'
          ? 'OTP expired. Please request a new one.'
          : e.message ?? 'Verification failed';
      return AuthResult(success: false, message: msg);
    } on DioException catch (e) {
      return AuthResult(success: false, message: e.response?.data['message'] ?? 'Verification failed');
    }
  }

  // ─── Other auth endpoints (unchanged) ────────────────────────────────────

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
    // Sign out of Firebase too if it was used
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    await _api.logout();
  }

  Future<bool> isLoggedIn() => _api.isLoggedIn();
}
