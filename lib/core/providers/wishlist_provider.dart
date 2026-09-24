import 'package:flutter/foundation.dart';
import '../models/wishlist_model.dart';
import '../models/user_model.dart';
import '../services/wishlist_service.dart';

enum WishlistState { idle, loading, loaded, error }

class WishlistProvider extends ChangeNotifier {
  final _wishlistService = WishlistService();
  final _profileService = ProfileService();

  // Wishlist
  List<WishlistItemModel> items = [];
  WishlistState wishlistState = WishlistState.idle;
  Set<String> _wishlistedProductIds = {};

  bool isWishlisted(String productId) => _wishlistedProductIds.contains(productId);

  Future<void> loadWishlist() async {
    wishlistState = WishlistState.loading;
    notifyListeners();
    items = await _wishlistService.getWishlist();
    _wishlistedProductIds = items.map((i) => i.productId).toSet();
    wishlistState = WishlistState.loaded;
    notifyListeners();
  }

  Future<bool> toggleWishlist(String productId) async {
    final result = await _wishlistService.toggle(productId);
    if (result == true) {
      _wishlistedProductIds.add(productId);
    } else if (result == false) {
      _wishlistedProductIds.remove(productId);
      items.removeWhere((i) => i.productId == productId);
    }
    notifyListeners();
    return result ?? false;
  }

  Future<void> removeItem(String wishlistItemId) async {
    final ok = await _wishlistService.remove(wishlistItemId);
    if (ok) {
      final removed = items.firstWhere((i) => i.id == wishlistItemId, orElse: () => items.first);
      _wishlistedProductIds.remove(removed.productId);
      items.removeWhere((i) => i.id == wishlistItemId);
      notifyListeners();
    }
  }

  // Profile
  UserModel? profile;
  WishlistState profileState = WishlistState.idle;
  List<ReviewModel> myReviews = [];
  List<NotificationModel> notifications = [];
  int unreadNotificationCount = 0;

  /// Drops everything that belongs to the signed-in user (called on logout).
  void reset() {
    items = [];
    _wishlistedProductIds = {};
    wishlistState = WishlistState.idle;
    profile = null;
    profileState = WishlistState.idle;
    myReviews = [];
    notifications = [];
    unreadNotificationCount = 0;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    profileState = WishlistState.loading;
    notifyListeners();
    profile = await _profileService.getProfile();
    profileState = WishlistState.loaded;
    notifyListeners();
  }

  Future<bool> updateProfile({String? name, String? email, String? avatarUrl}) async {
    final updated = await _profileService.updateProfile(name: name, email: email, avatarUrl: avatarUrl);
    if (updated != null) {
      profile = updated;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> uploadAvatar(String filePath) async {
    final updated = await _profileService.uploadAvatar(filePath);
    if (updated != null) {
      profile = updated;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> loadMyReviews() async {
    myReviews = await _profileService.getMyReviews();
    notifyListeners();
  }

  Future<bool> deleteReview(String productId, String reviewId) async {
    final ok = await _profileService.deleteReview(productId, reviewId);
    if (ok) {
      myReviews.removeWhere((r) => r.id == reviewId);
      notifyListeners();
    }
    return ok;
  }

  Future<void> loadNotifications() async {
    notifications = await _profileService.getNotifications();
    unreadNotificationCount = 0;
    notifyListeners();
  }

  Future<void> fetchUnreadCount() async {
    unreadNotificationCount = await _profileService.getUnreadCount();
    notifyListeners();
  }
}
