import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';

enum CartLoadState { idle, loading, loaded, error }

class CartProvider extends ChangeNotifier {
  final _cartService = CartService();
  final _addressService = AddressService();
  final _orderService = OrderService();

  // Cart
  List<CartItemModel> items = [];
  CartSummary summary = CartSummary();
  CartLoadState cartState = CartLoadState.idle;

  // Coupon
  String? appliedCouponCode;
  double couponDiscount = 0;
  String? couponMessage;

  // Addresses
  List<AddressModel> addresses = [];
  AddressModel? selectedAddress;
  CartLoadState addressState = CartLoadState.idle;

  // Orders
  List<OrderModel> orders = [];
  OrderModel? currentOrder;
  CartLoadState orderState = CartLoadState.idle;

  // Active coupons
  List<CouponModel> activeCoupons = [];

  int get cartCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Drops everything that belongs to the signed-in user (called on logout).
  void reset() {
    items = [];
    summary = CartSummary();
    cartState = CartLoadState.idle;
    appliedCouponCode = null;
    couponDiscount = 0;
    couponMessage = null;
    addresses = [];
    selectedAddress = null;
    addressState = CartLoadState.idle;
    orders = [];
    currentOrder = null;
    orderState = CartLoadState.idle;
    notifyListeners();
  }

  Future<void> loadCart() async {
    cartState = CartLoadState.loading;
    notifyListeners();
    final data = await _cartService.getCart();
    if (data != null) {
      final rawItems = data['items'] as List? ?? [];
      items = rawItems.map((e) => CartItemModel.fromJson(e)).toList();
      summary = CartSummary.fromJson(data['summary'] ?? {});
      if (data['coupon'] != null) {
        appliedCouponCode = data['coupon']['code'];
        couponDiscount = double.tryParse(data['coupon']['discount'].toString()) ?? 0;
      } else {
        appliedCouponCode = null;
        couponDiscount = 0;
      }
      cartState = CartLoadState.loaded;
    } else {
      cartState = CartLoadState.error;
    }
    notifyListeners();
  }

  Future<String?> addToCart(String productId, {int quantity = 1}) async {
    final result = await _cartService.addToCart(productId, quantity);
    if (result.success) await loadCart();
    return result.success ? null : result.message;
  }

  Future<String?> updateItem(String itemId, int quantity) async {
    final result = await _cartService.updateCartItem(itemId, quantity);
    if (result.success) await loadCart();
    return result.success ? null : result.message;
  }

  Future<String?> removeItem(String itemId) async {
    final result = await _cartService.removeCartItem(itemId);
    if (result.success) await loadCart();
    return result.success ? null : result.message;
  }

  Future<String?> applyCoupon(String code) async {
    final result = await _cartService.applyCoupon(code);
    if (result.success) {
      couponMessage = result.message;
      await loadCart();
      // loadCart() resets coupon to null because the backend doesn't persist it
      // in the cart table — re-apply from the API response data
      if (result.data != null) {
        appliedCouponCode = result.data['code']?.toString();
        couponDiscount = double.tryParse(result.data['discount'].toString()) ?? 0;
        notifyListeners();
      }
      return null;
    }
    return result.message;
  }

  void removeCoupon() {
    appliedCouponCode = null;
    couponDiscount = 0;
    couponMessage = null;
    loadCart();
  }

  Future<void> loadActiveCoupons() async {
    activeCoupons = await _cartService.getActiveCoupons();
    notifyListeners();
  }

  // Addresses
  Future<void> loadAddresses() async {
    addressState = CartLoadState.loading;
    notifyListeners();
    addresses = await _addressService.getAddresses();
    if (selectedAddress == null && addresses.isNotEmpty) {
      selectedAddress = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
      checkServiceability();
    }
    addressState = CartLoadState.loaded;
    notifyListeners();
  }

  void selectAddress(AddressModel address) {
    selectedAddress = address;
    notifyListeners();
    checkServiceability();
  }

  /// Delhivery serviceability of the selected address. null = unknown (never blocks checkout).
  bool? pincodeServiceable;
  bool? codAvailable;
  String? codUnavailableReason; // 'store' | 'pincode' | null
  Future<void> checkServiceability() async {
    final pin = selectedAddress?.pincode;
    pincodeServiceable = null;
    codAvailable = null;
    codUnavailableReason = null;
    notifyListeners();
    if (pin == null) return;
    try {
      final res = await ApiService().get('/shipping/pincode/$pin');
      final d = res.data['data'] as Map?;
      if (selectedAddress?.pincode != pin) return; // user switched address meanwhile
      pincodeServiceable = d?['serviceable'] as bool?;
      codAvailable = d?['cod'] as bool?;
      codUnavailableReason = d?['cod_reason'] as String?;
    } catch (_) {
      pincodeServiceable = null;
      codAvailable = null;
    }
    notifyListeners();
  }

  Future<String?> saveAddress(Map<String, dynamic> body, {String? existingId}) async {
    final result = existingId != null
        ? await _addressService.updateAddress(existingId, body)
        : await _addressService.createAddress(body);
    if (result.success) {
      await loadAddresses();
      return null;
    }
    return result.message;
  }

  Future<String?> deleteAddress(String id) async {
    final result = await _addressService.deleteAddress(id);
    if (result.success) {
      if (selectedAddress?.id == id) selectedAddress = null;
      await loadAddresses();
      return null;
    }
    return result.message;
  }

  Future<String?> setDefaultAddress(String id) async {
    final result = await _addressService.setDefault(id);
    if (result.success) await loadAddresses();
    return result.success ? null : result.message;
  }

  // Orders
  Future<OrderModel?> placeOrder({required String paymentMethod}) async {
    if (selectedAddress == null) return null;
    orderState = CartLoadState.loading;
    notifyListeners();
    final result = await _orderService.createOrder({
      'address_id': selectedAddress!.id,
      'payment_method': paymentMethod,
      if (appliedCouponCode != null) 'coupon_code': appliedCouponCode,
    });
    if (result.success) {
      currentOrder = OrderModel.fromJson(result.data);
      orderState = CartLoadState.loaded;
      // Reset cart UI state
      items = [];
      summary = CartSummary();
      appliedCouponCode = null;
      couponDiscount = 0;
      notifyListeners();
      return currentOrder;
    }
    orderState = CartLoadState.error;
    notifyListeners();
    return null;
  }

  Future<void> loadOrders({String? status}) async {
    orderState = CartLoadState.loading;
    notifyListeners();
    orders = await _orderService.getOrders(status: status);
    orderState = CartLoadState.loaded;
    notifyListeners();
  }

  Future<void> loadOrder(String id) async {
    final order = await _orderService.getOrder(id);
    if (order != null) {
      currentOrder = order;
      notifyListeners();
    }
  }

  Future<String?> cancelOrder(String id, String reason) async {
    final result = await _orderService.cancelOrder(id, reason);
    if (result.success) await loadOrders();
    return result.success ? null : result.message;
  }

  Future<String?> requestRefund(String id, String type, String reason) async {
    final result = await _orderService.requestRefund(id, type, reason);
    if (result.success) await loadOrder(id);
    return result.success ? null : result.message;
  }

  Future<Map<String, dynamic>?> initiatePhonePePayment(String orderId) async {
    final result = await _orderService.initiatePayment(orderId);
    if (result.success) return result.data as Map<String, dynamic>?;
    return null;
  }

  Future<String?> confirmCOD(String orderId) async {
    final result = await _orderService.confirmCOD(orderId);
    return result.success ? null : result.message;
  }
}
