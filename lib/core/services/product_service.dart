import 'api_service.dart';
import '../models/product_model.dart';

class ProductListResult {
  final List<ProductModel> products;
  final int total;
  final int page;
  final int pages;
  ProductListResult({required this.products, required this.total, required this.page, required this.pages});
}

class ProductService {
  final _api = ApiService();

  Future<ProductListResult> getProducts({
    String? category, String? brand, String? search,
    String sort = 'created_at', String order = 'DESC',
    int page = 1, int limit = 20,
    double? minPrice, double? maxPrice,
  }) async {
    final res = await _api.get('/products', params: {
      'category': ?category,
      'brand': ?brand,
      'search': ?search,
      'sort': sort, 'order': order,
      'page': page, 'limit': limit,
      'min_price': ?minPrice,
      'max_price': ?maxPrice,
    });
    final data = res.data['data'];
    return ProductListResult(
      products: (data['products'] as List).map((e) => ProductModel.fromJson(e)).toList(),
      total: data['total'],
      page: data['page'],
      pages: data['pages'],
    );
  }

  Future<ProductModel?> getProduct(String id) async {
    try {
      final res = await _api.get('/products/$id');
      return ProductModel.fromJson(res.data['data']['product']);
    } catch (_) { return null; }
  }

  Future<List<ProductModel>> getTrending({int limit = 10}) =>
      _getList('/products/trending', limit: limit);

  Future<List<ProductModel>> getNewArrivals({int limit = 10}) =>
      _getList('/products/new-arrivals', limit: limit);

  Future<List<ProductModel>> getFlashSale({int limit = 10}) =>
      _getList('/products/flash-sale', limit: limit);

  Future<List<ProductModel>> getFeatured({int limit = 10}) =>
      _getList('/products/featured', limit: limit);

  Future<List<ProductModel>> getRecommended({int limit = 10}) =>
      _getList('/products/recommended', limit: limit);

  Future<List<ProductModel>> getRecentlyViewed({int limit = 10}) =>
      _getList('/products/recently-viewed', limit: limit);

  Future<List<ProductModel>> getCategoryProducts(String categoryId, {int page = 1, int limit = 20}) async {
    try {
      final res = await _api.get('/categories/$categoryId/products', params: {'page': page, 'limit': limit});
      return (res.data['data']['products'] as List).map((e) => ProductModel.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  Future<void> logRecentlyViewed(String productId) async {
    try { await _api.post('/products/$productId/recently-viewed'); } catch (_) {}
  }

  Future<bool> removeRecentlyViewed(String productId) async {
    try { await _api.delete('/products/recently-viewed/$productId'); return true; } catch (_) { return false; }
  }

  Future<bool> clearRecentlyViewed() async {
    try { await _api.delete('/products/recently-viewed'); return true; } catch (_) { return false; }
  }

  Future<List<ProductModel>> _getList(String path, {int limit = 10}) async {
    try {
      final res = await _api.get(path, params: {'limit': limit});
      return (res.data['data']['products'] as List).map((e) => ProductModel.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await _api.get('/categories');
      return (res.data['data']['categories'] as List).map((e) => CategoryModel.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  Future<List<BrandModel>> getBrands() async {
    try {
      final res = await _api.get('/brands');
      return (res.data['data']['brands'] as List).map((e) => BrandModel.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  Future<Map<String, dynamic>?> getHomeData() async {
    try {
      final res = await _api.get('/home');
      return res.data['data'] as Map<String, dynamic>;
    } catch (_) { return null; }
  }

  Future<Map<String, dynamic>> search(String query, {int page = 1}) async {
    try {
      final res = await _api.get('/search', params: {'q': query, 'page': page});
      final data = res.data['data'];
      return {
        'products': (data['products'] as List).map((e) => ProductModel.fromJson(e)).toList(),
        'categories': data['categories'] ?? [],
        'brands': data['brands'] ?? [],
        'total': data['total'] ?? 0,
      };
    } catch (_) { return {'products': [], 'categories': [], 'brands': [], 'total': 0}; }
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final res = await _api.get('/search/suggestions', params: {'q': query});
      return (res.data['data']['suggestions'] as List).map((e) => e['name'].toString()).toList();
    } catch (_) { return []; }
  }

  Future<List<String>> getTrendingSearches() async {
    try {
      final res = await _api.get('/search/trending');
      return List<String>.from(res.data['data']['trending']);
    } catch (_) { return []; }
  }
}
