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
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

enum SortOrder { popular, priceLow, priceHigh, rating }

const _sortLabels = {
  SortOrder.popular: 'Popular',
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
  const ProductListingScreen({super.key, this.categoryId, this.categoryName, this.brandId, this.brandName, this.searchQuery});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  int _selectedChipIndex = 0;
  SortOrder _sortOrder = SortOrder.popular;
  bool _isGridView = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(
        category: widget.categoryId,
        brand: widget.brandId,
        search: widget.searchQuery,
        refresh: true,
      );
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<ProductProvider>().loadProducts(category: widget.categoryId, brand: widget.brandId);
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
                // Derive brand chips from loaded products
                final brands = pp.products
                    .map((p) => p.brandName ?? '')
                    .where((b) => b.isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort();

                // Apply brand filter
                final filtered = _selectedChipIndex == 0
                    ? pp.products
                    : (_selectedChipIndex - 1 < brands.length
                        ? pp.products.where((p) => (p.brandName ?? '') == brands[_selectedChipIndex - 1]).toList()
                        : pp.products);

                // Apply sort
                final displayProducts = List.of(filtered);
                if (_sortOrder == SortOrder.priceLow) {
                  displayProducts.sort((a, b) => a.price.compareTo(b.price));
                } else if (_sortOrder == SortOrder.priceHigh) {
                  displayProducts.sort((a, b) => b.price.compareTo(a.price));
                } else if (_sortOrder == SortOrder.rating) {
                  displayProducts.sort((a, b) => b.rating.compareTo(a.rating));
                }

                final wishlist = context.watch<WishlistProvider>();
                return Column(
                  children: [
                    ProductListingHeader(
                      title: widget.categoryName ?? "All Products",
                      productCount: "${displayProducts.length} Products",
                    ),
                    const ProductListingSearch(),
                    SizedBox(height: 12.h),
                    _buildFilterChips(brands),
                    Expanded(
                      child: pp.productsState == LoadState.loading && pp.products.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : displayProducts.isEmpty
                              ? Center(
                                  child: Text(
                                    'No products found',
                                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.greyText),
                                  ),
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
                                            "${displayProducts.length} Products",
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
                                            onAddToCart: () => context.read<CartProvider>().addToCart(p.id),
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
                activeFilterCount: _selectedChipIndex > 0 ? 1 : 0,
                onSort: _showSortSheet,
                onFilter: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Use the brand chips above to filter by brand'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
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
              icon: index == 0 ? Icons.grid_view_rounded : Icons.phone_android_rounded,
              isSelected: _selectedChipIndex == index,
              onTap: () => setState(() => _selectedChipIndex = index),
            ),
          ),
        ),
      ),
    );
  }
}
