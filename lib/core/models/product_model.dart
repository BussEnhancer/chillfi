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
        primaryImage: json['primary_image'],
        images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
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
