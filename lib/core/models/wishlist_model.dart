class WishlistItemModel {
  final String id;
  final String productId;
  final String name;
  final double price;
  final double? oldPrice;
  final double? rating;
  final int stock;
  final String? image;

  WishlistItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    this.oldPrice,
    this.rating,
    this.stock = 0,
    this.image,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> j) => WishlistItemModel(
        id: j['id'],
        productId: j['product_id'],
        name: j['name'],
        price: double.tryParse(j['price'].toString()) ?? 0,
        oldPrice: j['old_price'] != null ? double.tryParse(j['old_price'].toString()) : null,
        rating: j['rating'] != null ? double.tryParse(j['rating'].toString()) : null,
        stock: j['stock'] ?? 0,
        image: j['image'],
      );

  bool get inStock => stock > 0;

  int get discountPct =>
      oldPrice != null && oldPrice! > price ? ((oldPrice! - price) / oldPrice! * 100).round() : 0;
}

class ReviewModel {
  final String id;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final String productId;
  final String productName;
  final String? productImage;

  ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.productId,
    required this.productName,
    this.productImage,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> j) => ReviewModel(
        id: j['id'],
        rating: double.tryParse(j['rating'].toString()) ?? 0,
        comment: j['comment'],
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
        productId: j['product_id'],
        productName: j['product_name'],
        productImage: j['product_image'],
      );
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final String? type;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.type,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
        id: j['id'],
        title: j['title'] ?? '',
        body: j['body'] ?? '',
        isRead: j['is_read'] ?? false,
        type: j['type'],
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
      );
}
