import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/cart_model.dart';

class CartResult {
  final bool success;
  final String message;
  final dynamic data;
  CartResult({required this.success, required this.message, this.data});
}

class CartService {
  final _api = ApiService();

  Future<Map<String, dynamic>?> getCart() async {
    try {
      final res = await _api.get('/cart');
      return res.data['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<CartResult> addToCart(String productId, int quantity) async {
    try {
      final res = await _api.post('/cart/add', data: {'product_id': productId, 'quantity': quantity});
      return CartResult(success: true, message: res.data['message'] ?? 'Added to cart', data: res.data['data']);
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Failed to add to cart');
    }
  }

  Future<CartResult> updateCartItem(String itemId, int quantity) async {
    try {
      final res = await _api.put('/cart/item/$itemId', data: {'quantity': quantity});
      return CartResult(success: true, message: res.data['message'] ?? 'Updated', data: res.data['data']);
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Failed to update');
    }
  }

  Future<CartResult> removeCartItem(String itemId) async {
    try {
      final res = await _api.delete('/cart/item/$itemId');
      return CartResult(success: true, message: res.data['message'] ?? 'Removed');
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Failed to remove');
    }
  }

  Future<CartResult> clearCart() async {
    try {
      final res = await _api.delete('/cart/clear');
      return CartResult(success: true, message: res.data['message'] ?? 'Cart cleared');
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Failed to clear');
    }
  }

  Future<CartResult> applyCoupon(String code) async {
    try {
      final res = await _api.post('/cart/apply-coupon', data: {'code': code});
      return CartResult(success: true, message: res.data['message'] ?? 'Coupon applied', data: res.data['data']);
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Invalid coupon');
    }
  }

  Future<List<CouponModel>> getActiveCoupons() async {
    try {
      final res = await _api.get('/cart/coupons');
      final list = res.data['data'] as List? ?? [];
      return list.map((e) => CouponModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}

class AddressService {
  final _api = ApiService();

  Future<List<AddressModel>> getAddresses() async {
    try {
      final res = await _api.get('/addresses');
      final raw = res.data['data'];
      final list = (raw is List ? raw : (raw is Map ? raw['addresses'] : null)) as List? ?? [];
      return list.map((e) => AddressModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<CartResult> createAddress(Map<String, dynamic> body) async {
    try {
      final res = await _api.post('/addresses', data: body);
      return CartResult(success: true, message: 'Address saved', data: res.data['data']);
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Failed to save address');
    }
  }

  Future<CartResult> updateAddress(String id, Map<String, dynamic> body) async {
    try {
      final res = await _api.put('/addresses/$id', data: body);
      return CartResult(success: true, message: 'Address updated', data: res.data['data']);
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Failed to update');
    }
  }

  Future<CartResult> deleteAddress(String id) async {
    try {
      await _api.delete('/addresses/$id');
      return CartResult(success: true, message: 'Address deleted');
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Failed to delete');
    }
  }

  Future<CartResult> setDefault(String id) async {
    try {
      final res = await _api.put('/addresses/$id/set-default');
      return CartResult(success: true, message: res.data['message'] ?? 'Default updated');
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Failed');
    }
  }
}

class OrderService {
  final _api = ApiService();

  Future<CartResult> createOrder(Map<String, dynamic> body) async {
    try {
      final res = await _api.post('/orders', data: body);
      final raw = res.data['data'];
      final orderData = (raw is Map && raw['order'] != null) ? raw['order'] : raw;
      return CartResult(success: true, message: 'Order placed', data: orderData);
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Failed to place order');
    }
  }

  Future<List<OrderModel>> getOrders({String? status, int page = 1}) async {
    try {
      final res = await _api.get('/orders', params: {
        if (status != null) 'status': status,
        'page': page,
        'limit': 20,
      });
      final raw = res.data['data'];
      final list = (raw is List ? raw : (raw is Map ? raw['orders'] : null)) as List? ?? [];
      return list.map((e) => OrderModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<OrderModel?> getOrder(String id) async {
    try {
      final res = await _api.get('/orders/$id');
      final raw = res.data['data'];
      final orderData = (raw is Map && raw['order'] != null) ? raw['order'] : raw;
      return OrderModel.fromJson(orderData);
    } catch (_) {
      return null;
    }
  }

  Future<CartResult> cancelOrder(String id, String reason) async {
    try {
      final res = await _api.post('/orders/$id/cancel', data: {'reason': reason});
      return CartResult(success: true, message: res.data['message'] ?? 'Order cancelled');
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Failed to cancel');
    }
  }

  Future<CartResult> requestRefund(String id, String type, String reason) async {
    try {
      final res = await _api.post('/orders/$id/refund-request', data: {'type': type, 'reason': reason});
      return CartResult(success: true, message: res.data['message'] ?? 'Request submitted');
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Failed to submit request');
    }
  }

  Future<CartResult> initiatePayment(String orderId) async {
    try {
      final res = await _api.post('/payment/initiate', data: {'order_id': orderId});
      return CartResult(success: true, message: 'Payment initiated', data: res.data['data']);
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Payment failed');
    }
  }

  Future<CartResult> confirmCOD(String orderId) async {
    try {
      final res = await _api.post('/payment/cod-confirm', data: {'order_id': orderId});
      return CartResult(success: true, message: res.data['message'] ?? 'Order confirmed');
    } on DioException catch (e) {
      return CartResult(success: false, message: e.response?.data?['message'] ?? 'Failed');
    }
  }
}
