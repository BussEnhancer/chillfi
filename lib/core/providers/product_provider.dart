import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

enum LoadState { idle, loading, loaded, error }

class HomeData {
  final List<dynamic> banners;
  final List<CategoryModel> categories;
  final List<ProductModel> flashSale;
  final List<ProductModel> trending;
  final List<ProductModel> featured;
  final List<BrandModel> brands;

  HomeData({
    this.banners = const [],
    this.categories = const [],
    this.flashSale = const [],
    this.trending = const [],
    this.featured = const [],
    this.brands = const [],
  });
}

class ProductProvider extends ChangeNotifier {
  final _service = ProductService();

  // Home
  HomeData _home = HomeData();
  LoadState _homeState = LoadState.idle;

  // Product listing
  List<ProductModel> _products = [];
  LoadState _productsState = LoadState.idle;
  int _currentPage = 1;
  bool _hasMore = true;

  // Product detail
  ProductModel? _selectedProduct;
  LoadState _detailState = LoadState.idle;

  // Search
  List<ProductModel> _searchResults = [];
  List<String> _suggestions = [];
  List<String> _trendingSearches = [];
  LoadState _searchState = LoadState.idle;

  // Categories
  List<CategoryModel> _categories = [];
  List<BrandModel> _brands = [];

  // Getters
  HomeData get home => _home;
  LoadState get homeState => _homeState;
  List<ProductModel> get products => _products;
  LoadState get productsState => _productsState;
  bool get hasMore => _hasMore;
  ProductModel? get selectedProduct => _selectedProduct;
  LoadState get detailState => _detailState;
  List<ProductModel> get searchResults => _searchResults;
  List<String> get suggestions => _suggestions;
  List<String> get trendingSearches => _trendingSearches;
  LoadState get searchState => _searchState;
  List<CategoryModel> get categories => _categories;
  List<BrandModel> get brands => _brands;

  Future<void> loadHome() async {
    _homeState = LoadState.loading;
    notifyListeners();

    final data = await _service.getHomeData();
    if (data != null) {
      _home = HomeData(
        banners: data['banners'] ?? [],
        categories: (data['categories'] as List? ?? []).map((e) => CategoryModel.fromJson(e)).toList(),
        flashSale: (data['flash_sale'] as List? ?? []).map((e) => ProductModel.fromJson(e)).toList(),
        trending: (data['trending'] as List? ?? []).map((e) => ProductModel.fromJson(e)).toList(),
        featured: (data['featured'] as List? ?? []).map((e) => ProductModel.fromJson(e)).toList(),
        brands: (data['brands'] as List? ?? []).map((e) => BrandModel.fromJson(e)).toList(),
      );
      _homeState = LoadState.loaded;
    } else {
      _homeState = LoadState.error;
    }
    notifyListeners();
  }

  int _productsTotal = 0;
  int get productsTotal => _productsTotal;

  Future<void> loadProducts({
    String? category, String? brand, String? search,
    String sort = 'created_at', String order = 'DESC',
    double? minPrice, double? maxPrice,
    bool refresh = false,
  }) async {
    if (refresh) {
      _products = [];
      _currentPage = 1;
      _hasMore = true;
    }
    if (!_hasMore) return;

    _productsState = LoadState.loading;
    notifyListeners();

    try {
      final result = await _service.getProducts(
        category: category, brand: brand, search: search,
        sort: sort, order: order, page: _currentPage,
        minPrice: minPrice, maxPrice: maxPrice,
      );
      _products = refresh ? result.products : [..._products, ...result.products];
      _productsTotal = result.total;
      _hasMore = _currentPage < result.pages;
      _currentPage++;
      _productsState = LoadState.loaded;
    } catch (_) {
      _productsState = LoadState.error;
    }
    notifyListeners();
  }

  /// Set when the product failed to load: [detailGone] = removed/deactivated (404), else [detailError] is a friendly reason.
  bool detailGone = false;
  String? detailError;

  Future<void> loadProduct(String id) async {
    _detailState = LoadState.loading;
    detailGone = false;
    detailError = null;
    notifyListeners();
    try {
      _selectedProduct = await _service.getProduct(id);
      _detailState = LoadState.loaded;
    } catch (e) {
      _selectedProduct = null;
      _detailState = LoadState.error;
      detailGone = e is DioException && e.response?.statusCode == 404;
      detailError = AppError.message(e, fallback: "This product couldn't be loaded. Please try again.");
    }
    notifyListeners();
    if (_selectedProduct != null) _service.logRecentlyViewed(id);
  }

  Future<void> searchProducts(String query) async {
    // Always re-fetch: prices/availability may have changed since the last identical search.
    _searchState = LoadState.loading;
    notifyListeners();

    final result = await _service.search(query);
    _searchResults = result['products'] as List<ProductModel>;
    _searchState = LoadState.loaded;
    notifyListeners();
  }

  Future<void> loadSuggestions(String query) async {
    if (query.isEmpty) { _suggestions = []; notifyListeners(); return; }
    _suggestions = await _service.getSearchSuggestions(query);
    notifyListeners();
  }

  Future<void> loadTrendingSearches() async {
    _trendingSearches = await _service.getTrendingSearches();
    notifyListeners();
  }

  LoadState _categoriesState = LoadState.idle;
  LoadState get categoriesState => _categoriesState;

  Future<void> loadCategories() async {
    _categoriesState = LoadState.loading;
    notifyListeners();
    _categories = await _service.getCategories();
    // getCategories() returns [] on failure; an empty active list is treated as "couldn't load"
    _categoriesState = _categories.isEmpty ? LoadState.error : LoadState.loaded;
    notifyListeners();
  }

  Future<void> loadBrands() async {
    _brands = await _service.getBrands();
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _suggestions = [];
    _searchState = LoadState.idle;
    notifyListeners();
  }
}
