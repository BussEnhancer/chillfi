import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:chillfi/core/widgets/cart_feedback.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/providers/product_provider.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/features/categories/widgets/feature_highlights.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/product_listing/widgets/bottom_action_bar.dart';
import 'package:chillfi/features/product_listing/widgets/category_filter_chips.dart';
import 'package:chillfi/features/product_listing/widgets/product_card.dart';
import 'package:chillfi/features/product_listing/widgets/product_listing_header.dart';
import 'package:chillfi/features/product_listing/widgets/product_listing_search.dart';
import 'package:chillfi/core/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

enum SortOrder { popular, priceLow, priceHigh, rating }

const _sortLabels = {
  SortOrder.popular: 'Newest',
  SortOrder.priceLow: 'Price: Low to High',
  SortOrder.priceHigh: 'Price: High to Low',
  SortOrder.rating: 'Top Rated',
};

class ProductListingScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final String? brandId;
  final String? brandName;
  final String? searchQuery;
  /// Optional preset price filter (index into the Filter sheet's ranges, e.g. 0 = under ₹1,000).
  final int? initialPriceIdx;
  final String? title;
  const ProductListingScreen({super.key, this.categoryId, this.categoryName, this.brandId, this.brandName, this.searchQuery, this.initialPriceIdx, this.title});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  int _selectedChipIndex = 0;
  SortOrder _sortOrder = SortOrder.popular;
  List<String> _brandChips = [];
  String? _brand;
  String? _search;
  int _priceIdx = -1; // index into _priceRanges, -1 = any

  static const _priceRanges = [
    ('Under ₹1,000', null, 1000.0),
    ('₹1,000 – ₹5,000', 1000.0, 5000.0),
    ('₹5,000 – ₹20,000', 5000.0, 20000.0),
    ('Above ₹20,000', 20000.0, null),
  ];

  /// Loads products with every active filter so each page uses the same query.
  void _load({bool refresh = true}) {
    final (sort, order) = switch (_sortOrder) {
      SortOrder.priceLow => ('price', 'ASC'),
      SortOrder.priceHigh => ('price', 'DESC'),
      SortOrder.rating => ('rating', 'DESC'),
      SortOrder.popular => ('newest', 'DESC'),
    };
    final range = _priceIdx >= 0 ? _priceRanges[_priceIdx] : null;
    context.read<ProductProvider>().loadProducts(
      category: widget.categoryId,
      brand: _brand ?? widget.brandId,
      search: _search,
      sort: sort,
      order: order,
      minPrice: range?.$2,
      maxPrice: range?.$3,
      refresh: refresh,
    );
  }
  bool _isGridView = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _search = widget.searchQuery;
    _priceIdx = widget.initialPriceIdx ?? -1;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _scrollController.addListener(() {
      final pp = context.read<ProductProvider>();
      if (pp.productsState != LoadState.loading &&
          _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _load(refresh: false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sort by', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
              SizedBox(height: 16.h),
              ...SortOrder.values.map((option) {
                final isSelected = _sortOrder == option;
                return GestureDetector(
                  onTap: () {
                    setState(() => _sortOrder = option);
                    Navigator.pop(ctx);
                    _load();
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondaryPurple.withValues(alpha: 0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _sortLabels[option]!,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? AppColors.secondaryPurple : AppColors.darkText,
                            ),
                          ),
                        ),
                        if (isSelected) Icon(Icons.check_rounded, color: AppColors.secondaryPurple, size: 18.sp),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Filter by price', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText))),
                if (_priceIdx >= 0)
                  TextButton(
                    onPressed: () {
                      setState(() => _priceIdx = -1);
                      Navigator.pop(ctx);
                      _load();
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            ...List.generate(_priceRanges.length, (i) {
              final selected = _priceIdx == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _priceIdx = i);
                  Navigator.pop(ctx);
                  _load();
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.secondaryPurple.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: selected ? AppColors.secondaryPurple : AppColors.lightGrey.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_priceRanges[i].$1,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? AppColors.secondaryPurple : AppColors.darkText,
                            )),
                      ),
                      if (selected) Icon(Icons.check_rounded, color: AppColors.secondaryPurple, size: 18.sp),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Consumer<ProductProvider>(
              builder: (context, pp, _) {
                // Brand chips come from the unfiltered result so they don't disappear once a brand is picked.
                if (_brand == null && _priceIdx < 0 && pp.productsState == LoadState.loaded) {
                  final names = {..._brandChips, ...pp.products.map((p) => p.brandName ?? '').where((b) => b.isNotEmpty)}.toList()..sort();
                  _brandChips = names;
                }
                final brands = _brandChips;
                // Sorting & filtering are done by the server (consistent across pages).
                final displayProducts = pp.products;

                final wishlist = context.watch<WishlistProvider>();
                final cart = context.watch<CartProvider>();
                return Column(
                  children: [
                    ProductListingHeader(
                      title: widget.title ?? widget.categoryName ?? widget.brandName ?? (widget.searchQuery != null ? '"${widget.searchQuery}"' : "All Products"),
                      productCount: "${pp.productsTotal} ${pp.productsTotal == 1 ? "Product" : "Products"}",
                    ),
                    ProductListingSearch(
                      initialText: _search,
                      onSubmitted: (q) {
                        _search = q.trim().isEmpty ? null : q.trim();
                        _load();
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildFilterChips(brands),
                    Expanded(
                      child: pp.productsState == LoadState.loading && pp.products.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : pp.productsState == LoadState.error && pp.products.isEmpty
                          ? Center(child: SingleChildScrollView(child: AppErrorState(onRetry: _load)))
                          : displayProducts.isEmpty
                              ? const AppEmptyState(
                                  icon: Icons.inventory_2_outlined,
                                  title: 'No products found',
                                  message: 'Try another filter or category',
                                )
                              : SingleChildScrollView(
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 16.h),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${pp.productsTotal} ${pp.productsTotal == 1 ? "Product" : "Products"}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: _showSortSheet,
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Sort by: ",
                                                  style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText),
                                                ),
                                                Text(
                                                  _sortLabels[_sortOrder]!,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.secondaryPurple,
                                                  ),
                                                ),
                                                Icon(Icons.keyboard_arrow_down_rounded, size: 16.sp, color: AppColors.secondaryPurple),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.h),
                                      const FeatureHighlightsRow(),
                                      SizedBox(height: 20.h),
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: _isGridView
                                            ? SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 0.62,
                                                crossAxisSpacing: 12.w,
                                                mainAxisSpacing: 15.h,
                                              )
                                            : SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 1,
                                                mainAxisExtent: 260.h,
                                                crossAxisSpacing: 12.w,
                                                mainAxisSpacing: 15.h,
                                              ),
                                        itemCount: displayProducts.length,
                                        itemBuilder: (context, index) {
                                          final p = displayProducts[index];
                                          return ProductListingCard(
                                            id: p.id,
                                            title: p.name,
                                            variant: p.brandName ?? p.categoryName ?? '',
                                            price: p.price.toStringAsFixed(0),
                                            oldPrice: (p.oldPrice ?? p.price).toStringAsFixed(0),
                                            discount: '${p.discountPct}%',
                                            savings: ((p.oldPrice ?? p.price) - p.price).toStringAsFixed(0),
                                            rating: p.rating,
                                            reviews: p.reviewCount > 999 ? '${(p.reviewCount / 1000).toStringAsFixed(1)}k' : '${p.reviewCount}',
                                            imageUrl: p.primaryImage,
                                            isWishlisted: wishlist.isWishlisted(p.id),
                                            onWishlistToggle: () => wishlist.toggleWishlist(p.id),
                                            onAddToCart: () => addToCartWithFeedback(context, p.id, productName: p.name),
                                            inStock: p.inStock,
                                            isInCart: cart.isInCart(p.id),
                                          );
                                        },
                                      ),
                                      if (pp.productsState == LoadState.loading)
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20.h),
                                          child: const Center(child: CircularProgressIndicator()),
                                        ),
                                      SizedBox(height: 100.h),
                                    ],
                                  ),
                                ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 20.h,
              child: BottomActionBar(
                isGridView: _isGridView,
                activeFilterCount: (_brand != null ? 1 : 0) + (_priceIdx >= 0 ? 1 : 0),
                onSort: _showSortSheet,
                onFilter: _showFilterSheet,
                onGrid: () => setState(() => _isGridView = !_isGridView),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildFilterChips(List<String> brands) {
    final allChips = ['All', ...brands];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(
          allChips.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: CategoryFilterChip(
              label: allChips[index],
              icon: index == 0 ? Icons.grid_view_rounded : Icons.sell_outlined,
              isSelected: _selectedChipIndex == index,
              onTap: () {
                setState(() {
                  _selectedChipIndex = index;
                  _brand = index == 0 ? null : allChips[index];
                });
                _load();
              },
            ),
          ),
        ),
      ),
    );
  }
}
