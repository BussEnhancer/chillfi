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

class ProductListingScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final String? searchQuery;
  const ProductListingScreen({super.key, this.categoryId, this.categoryName, this.searchQuery});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  int _selectedChipIndex = 0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(
        category: widget.categoryId,
        search: widget.searchQuery,
        refresh: true,
      );
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<ProductProvider>().loadProducts(category: widget.categoryId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _filterChips = [
    {'label': 'All', 'icon': Icons.grid_view_rounded},
    {'label': 'Smartphones', 'icon': Icons.smartphone_rounded},
    {'label': 'Tablets', 'icon': Icons.tablet_rounded},
    {'label': 'Feature Phones', 'icon': Icons.phone_android_rounded},
    {'label': 'Filter', 'icon': Icons.tune_rounded},
  ];

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
                final products = pp.products;
                final wishlist = context.watch<WishlistProvider>();
                return Column(
                  children: [
                    ProductListingHeader(
                      title: widget.categoryName ?? "All Products",
                      productCount: "${products.length} Products",
                    ),
                    const ProductListingSearch(),
                    SizedBox(height: 12.h),
                    _buildFilterChips(),
                    Expanded(
                      child: pp.productsState == LoadState.loading && products.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : products.isEmpty
                              ? Center(
                                  child: Text(
                                    'No products found',
                                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.greyText),
                                  ),
                                )
                              : SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 16.h),
                                      // Count and Sort Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${products.length} Products",
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Sort by: ",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.sp,
                                                  color: AppColors.greyText,
                                                ),
                                              ),
                                              Text(
                                                "Popular",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.secondaryPurple,
                                                ),
                                              ),
                                              Icon(Icons.keyboard_arrow_down_rounded, size: 16.sp, color: AppColors.secondaryPurple),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.h),
                                      // Benefit Strip (Reused)
                                      const FeatureHighlightsRow(),
                                      SizedBox(height: 20.h),
                                      // Product Grid
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.62,
                                          crossAxisSpacing: 12.w,
                                          mainAxisSpacing: 15.h,
                                        ),
                                        itemCount: products.length,
                                        itemBuilder: (context, index) {
                                          final p = products[index];
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
                                      SizedBox(height: 100.h), // Space for floating bar
                                    ],
                                  ),
                                ),
                    ),
                  ],
                );
              },
            ),
            // Floating Bottom Toolbar
            Positioned(
              bottom: 20.h,
              child: const BottomActionBar(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(
          _filterChips.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: CategoryFilterChip(
              label: _filterChips[index]['label'],
              icon: _filterChips[index]['icon'],
              isSelected: _selectedChipIndex == index,
              onTap: () => setState(() => _selectedChipIndex = index),
            ),
          ),
        ),
      ),
    );
  }
}
