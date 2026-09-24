import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/wishlist_model.dart';
import '../models/user_model.dart';

class WishlistService {
  final _api = ApiService();

  Future<List<WishlistItemModel>> getWishlist() async {
    try {
      final res = await _api.get('/wishlist');
      final list = res.data['data'] as List? ?? [];
      return list.map((e) => WishlistItemModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool?> toggle(String productId) async {
    try {
      final res = await _api.post('/wishlist/toggle', data: {'product_id': productId});
      return res.data['data']['wishlisted'] as bool?;
    } catch (_) {
      return null;
    }
  }

  Future<bool> remove(String wishlistItemId) async {
    try {
      await _api.delete('/wishlist/$wishlistItemId');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool?> isWishlisted(String productId) async {
    try {
      final res = await _api.get('/wishlist/check/$productId');
      return res.data['data']['wishlisted'] as bool?;
    } catch (_) {
      return null;
    }
  }
}

class ProfileService {
  final _api = ApiService();

  Future<UserModel?> getProfile() async {
    try {
      final res = await _api.get('/profile');
      return UserModel.fromJson(res.data['data']);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel?> updateProfile({String? name, String? email, String? avatarUrl}) async {
    try {
      final res = await _api.put('/profile', data: {
        'name': ?name,
        'email': ?email,
        'avatar_url': ?avatarUrl,
      });
      return UserModel.fromJson(res.data['data']);
    } on DioException {
      return null;
    }
  }

  Future<UserModel?> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      final res = await _api.post('/profile/avatar', data: formData);
      return UserModel.fromJson(res.data['data']);
    } on DioException {
      return null;
    }
  }

  Future<List<ReviewModel>> getMyReviews({int page = 1}) async {
    try {
      final res = await _api.get('/profile/reviews', params: {'page': page});
      final list = res.data['data'] as List? ?? [];
      return list.map((e) => ReviewModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> deleteReview(String productId, String reviewId) async {
    try {
      await _api.delete('/products/$productId/reviews/$reviewId');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    try {
      final res = await _api.get('/profile/notifications', params: {'page': page});
      final list = res.data['data'] as List? ?? [];
      return list.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _api.get('/profile/notifications/unread-count');
      return res.data['data']['count'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> getNotificationPreferences() async {
    try {
      final res = await _api.get('/profile/notification-preferences');
      return Map<String, dynamic>.from(res.data['data'] ?? {});
    } catch (_) {
      return {};
    }
  }

  Future<bool> updateNotificationPreferences(Map<String, dynamic> prefs) async {
    try {
      await _api.put('/profile/notification-preferences', data: prefs);
      return true;
    } catch (_) {
      return false;
    }
  }
}
