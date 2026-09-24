/// Picks the best available primary image from a product JSON map.
/// Priority: top-level primary_image > images[is_primary=true].url > images[0].url (flat string)
String? _parsePrimaryImage(Map<String, dynamic> json) {
  // 1. Top-level field (list/search/home APIs)
  if (json['primary_image'] is String && (json['primary_image'] as String).isNotEmpty) {
    return json['primary_image'] as String;
  }
  final rawImages = json['images'] as List<dynamic>?;
  if (rawImages == null || rawImages.isEmpty) return null;

  // 2. Object array (detail API) — prefer is_primary=true
  final primary = rawImages
      .whereType<Map>()
      .where((e) => e['is_primary'] == true)
      .map((e) => e['url']?.toString())
      .whereType<String>()
      .where((u) => u.isNotEmpty)
      .firstOrNull;
  if (primary != null) return primary;

  // 3. First object URL
  final firstObj = rawImages
      .whereType<Map>()
      .map((e) => e['url']?.toString())
      .whereType<String>()
      .where((u) => u.isNotEmpty)
      .firstOrNull;
  if (firstObj != null) return firstObj;

  // 4. Flat string (list API)
  return rawImages
      .whereType<String>()
      .where((u) => u.isNotEmpty)
      .firstOrNull;
}

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? oldPrice;
  final int stock;
  final String? brandName;
  final String? categoryName;
  final String? categoryId;
  final double rating;
  final int reviewCount;
  final String status;
  final bool isFeatured;
  final bool isFlashSale;
  final String? primaryImage;
  final List<String> images;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.oldPrice,
    this.stock = 0,
    this.brandName,
    this.categoryName,
    this.categoryId,
    this.rating = 0,
    this.reviewCount = 0,
    this.status = 'Active',
    this.isFeatured = false,
    this.isFlashSale = false,
    this.primaryImage,
    this.images = const [],
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: double.tryParse(json['price'].toString()) ?? 0,
        oldPrice: json['old_price'] != null ? double.tryParse(json['old_price'].toString()) : null,
        stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
        brandName: json['brand_name'],
        categoryName: json['category_name'],
        categoryId: json['category_id'],
        rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
        reviewCount: int.tryParse(json['review_count']?.toString() ?? '0') ?? 0,
        status: json['status'] ?? 'Active',
        isFeatured: json['is_featured'] ?? false,
        isFlashSale: json['is_flash_sale'] ?? false,
        images: (json['images'] as List<dynamic>?)
                ?.map((e) => e is Map ? (e['url'] as String? ?? '') : e.toString())
                .where((e) => e.isNotEmpty)
                .toList() ?? [],
        primaryImage: _parsePrimaryImage(json),
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      );

  int get discountPct => (oldPrice != null && oldPrice! > price)
      ? ((oldPrice! - price) / oldPrice! * 100).round()
      : 0;

  bool get hasDiscount => discountPct > 0;
  bool get inStock => stock > 0 && status != 'Out of Stock';
}

class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final String? imageUrl;
  final String? description;
  final bool isActive;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.imageUrl,
    this.description,
    this.isActive = true,
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'],
        name: json['name'],
        icon: json['icon'],
        imageUrl: json['image_url'],
        description: json['description'],
        isActive: json['is_active'] ?? true,
        productCount: int.tryParse(json['product_count']?.toString() ?? '0') ?? 0,
      );
}

class BrandModel {
  final String id;
  final String name;
  final String? logoUrl;
  final int productCount;

  BrandModel({required this.id, required this.name, this.logoUrl, this.productCount = 0});

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
        id: json['id'],
        name: json['name'],
        logoUrl: json['logo_url'],
        productCount: int.tryParse(json['product_count']?.toString() ?? '0') ?? 0,
      );
}
