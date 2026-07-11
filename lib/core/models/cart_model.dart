class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final double price;
  final double? oldPrice;
  final int quantity;
  final int stock;
  final String? brandName;
  final String? image;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    this.oldPrice,
    required this.quantity,
    this.stock = 0,
    this.brandName,
    this.image,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> j) => CartItemModel(
        id: j['id'],
        productId: j['product_id'],
        name: j['name'],
        price: double.tryParse(j['price'].toString()) ?? 0,
        oldPrice: j['old_price'] != null ? double.tryParse(j['old_price'].toString()) : null,
        quantity: j['quantity'] ?? 1,
        stock: j['stock'] ?? 0,
        brandName: j['brand_name'],
        image: j['image'],
      );

  double get lineTotal => price * quantity;
  double get lineSaving => oldPrice != null ? (oldPrice! - price) * quantity : 0;
}

class CartSummary {
  final int itemCount;
  final double subtotal;
  final double savings;
  final double deliveryFee;
  final double taxAmount;
  final double total;

  CartSummary({
    this.itemCount = 0,
    this.subtotal = 0,
    this.savings = 0,
    this.deliveryFee = 0,
    this.taxAmount = 0,
    this.total = 0,
  });

  factory CartSummary.fromJson(Map<String, dynamic> j) => CartSummary(
        itemCount: j['item_count'] ?? 0,
        subtotal: double.tryParse(j['subtotal'].toString()) ?? 0,
        savings: double.tryParse(j['savings'].toString()) ?? 0,
        deliveryFee: double.tryParse(j['delivery_fee'].toString()) ?? 0,
        taxAmount: double.tryParse(j['tax_amount'].toString()) ?? 0,
        total: double.tryParse(j['total'].toString()) ?? 0,
      );
}

class AddressModel {
  final String id;
  final String label;
  final String name;
  final String phone;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> j) => AddressModel(
        id: j['id'],
        label: j['label'] ?? 'Home',
        name: j['name'],
        phone: j['phone'],
        line1: j['line1'],
        line2: j['line2'],
        city: j['city'],
        state: j['state'],
        pincode: j['pincode'],
        isDefault: j['is_default'] ?? false,
      );

  String get fullAddress => [line1, line2, city, state, pincode].where((e) => e != null && e!.isNotEmpty).join(', ');
}

class OrderModel {
  final String id;
  final String orderNumber;
  final double total;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double taxAmount;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String? trackingId;
  final DateTime createdAt;
  final List<OrderItemModel> items;
  final RefundRequestModel? refundRequest;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.total,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    this.taxAmount = 0,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.trackingId,
    required this.createdAt,
    this.items = const [],
    this.refundRequest,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: j['id'],
        orderNumber: j['order_number'],
        total: double.tryParse(j['total'].toString()) ?? 0,
        subtotal: double.tryParse(j['subtotal'].toString()) ?? 0,
        discount: double.tryParse(j['discount'].toString()) ?? 0,
        deliveryFee: double.tryParse(j['delivery_fee'].toString()) ?? 0,
        taxAmount: double.tryParse(j['tax_amount'].toString()) ?? 0,
        status: j['status'] ?? 'Processing',
        paymentMethod: j['payment_method'] ?? 'COD',
        paymentStatus: j['payment_status'] ?? 'Pending',
        trackingId: j['tracking_id'],
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
        items: (j['items'] as List? ?? []).map((e) => OrderItemModel.fromJson(e)).toList(),
        refundRequest: j['refund_request'] != null ? RefundRequestModel.fromJson(j['refund_request']) : null,
      );
}

class RefundRequestModel {
  final String id;
  final String type;
  final String status;
  final String reason;

  RefundRequestModel({required this.id, required this.type, required this.status, required this.reason});

  factory RefundRequestModel.fromJson(Map<String, dynamic> j) => RefundRequestModel(
        id: j['id'],
        type: j['type'] ?? 'Refund',
        status: j['status'] ?? 'Requested',
        reason: j['reason'] ?? '',
      );
}

class OrderItemModel {
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> j) => OrderItemModel(
        productName: j['product_name'] ?? j['name'] ?? '',
        productImage: j['product_image'] ?? j['image'],
        price: double.tryParse(j['price'].toString()) ?? 0,
        quantity: j['quantity'] ?? 1,
      );
}

class CouponModel {
  final String id;
  final String code;
  final String type;
  final double value;
  final double minOrder;
  final double maxDiscount;
  final String? expiresAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minOrder,
    required this.maxDiscount,
    this.expiresAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> j) => CouponModel(
        id: j['id'],
        code: j['code'],
        type: j['type'] ?? 'Percentage',
        value: double.tryParse(j['value'].toString()) ?? 0,
        minOrder: double.tryParse(j['min_order'].toString()) ?? 0,
        maxDiscount: double.tryParse(j['max_discount'].toString()) ?? 0,
        expiresAt: j['expires_at'],
      );

  String get description {
    switch (type) {
      case 'Percentage': return '${value.toStringAsFixed(0)}% OFF';
      case 'Flat': return '₹${value.toStringAsFixed(0)} OFF';
      case 'Free Shipping': return 'FREE Delivery';
      default: return 'Discount';
    }
  }
}
