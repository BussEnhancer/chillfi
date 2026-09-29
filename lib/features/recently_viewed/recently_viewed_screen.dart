import 'package:chillfi/core/widgets/cart_feedback.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/product_model.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/services/product_service.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/product_details/product_details_screen.dart';
import 'package:chillfi/features/recently_viewed/widgets/continue_exploring_card.dart';
import 'package:chillfi/features/recently_viewed/widgets/recently_viewed_banner.dart';
import 'package:chillfi/features/recently_viewed/widgets/recently_viewed_header.dart';
import 'package:chillfi/features/recently_viewed/widgets/recently_viewed_product_card.dart';
import 'package:chillfi/features/recently_viewed/widgets/recommendation_product_card.dart';
import 'package:chillfi/features/recently_viewed/widgets/view_all_cta_card.dart';
import 'package:chillfi/core/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RecentlyViewedScreen extends StatefulWidget {
  const RecentlyViewedScreen({super.key});

  @override
  State<RecentlyViewedScreen> createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen> {
  final _service = ProductService();
  List<ProductModel> _recentlyViewed = [];
  List<ProductModel> _recommendations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _service.getRecentlyViewed(limit: 20),
      _service.getRecommended(limit: 6),
    ]);
    if (!mounted) return;
    setState(() {
      _recentlyViewed = results[0];
      _recommendations = results[1];
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    final ok = await _service.clearRecentlyViewed();
    if (!ok || !mounted) return;
    setState(() => _recentlyViewed = []);
  }

  Future<void> _removeOne(String productId) async {
    final ok = await _service.removeRecentlyViewed(productId);
    if (!ok || !mounted) return;
    setState(() => _recentlyViewed.removeWhere((p) => p.id == productId));
  }

  Future<void> _addToCart(String productId) async {
    await addToCartWithFeedback(context, productId);
  }

  void _openProduct(String productId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: productId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const RecentlyViewedHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      const RecentlyViewedBanner(),
                      SizedBox(height: 24.h),

                      // Count and Clear All
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_recentlyViewed.length} Items',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                          if (_recentlyViewed.isNotEmpty)
                            GestureDetector(
                              onTap: _clearAll,
                              child: Row(
                                children: [
                                  Text(
                                    "Clear All",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFF5E5E),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(Icons.delete_outline_rounded, size: 18.sp, color: const Color(0xFFFF5E5E)),
                                ],
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Recently Viewed Grid
                      if (_loading)
                        Padding(padding: EdgeInsets.symmetric(vertical: 40.h), child: const Center(child: CircularProgressIndicator()))
                      else if (_recentlyViewed.isEmpty)
                        const AppEmptyState(
                          compact: true,
                          icon: Icons.history_rounded,
                          title: 'No recently viewed products yet',
                          message: 'Products you open will be saved here',
                        )
                      else
                        _buildRecentlyViewedGrid(),

                      SizedBox(height: 24.h),
                      const ViewAllRecentlyViewedCard(),

                      if (_recommendations.isNotEmpty) ...[
                        SizedBox(height: 30.h),
                        _buildSectionHeader("Because you viewed", showViewAll: false),
                        SizedBox(height: 16.h),
                        _buildRecommendationsList(),
                      ],

                      SizedBox(height: 30.h),
                      _buildSectionHeader("Continue Exploring", showViewAll: false),
                      SizedBox(height: 16.h),
                      _buildContinueExploringList(),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0), // Adjusting index if necessary
    );
  }

  Widget _buildSectionHeader(String title, {bool showViewAll = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        if (showViewAll)
          Text(
            "View All >",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryPurple,
            ),
          ),
      ],
    );
  }

  Widget _buildRecentlyViewedGrid() {
    final cart = context.watch<CartProvider>();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: _recentlyViewed.length,
      itemBuilder: (context, index) {
        final p = _recentlyViewed[index];
        return RecentlyViewedProductCard(
          title: p.name,
          variant: p.brandName ?? p.categoryName ?? '',
          price: p.price.toStringAsFixed(0),
          rating: p.rating,
          reviews: p.reviewCount > 999 ? '${(p.reviewCount / 1000).toStringAsFixed(1)}k' : '${p.reviewCount}',
          imageUrl: p.primaryImage,
          onTap: () => _openProduct(p.id),
          onRemove: () => _removeOne(p.id),
          onAddToCart: () => _addToCart(p.id),
          isInCart: cart.isInCart(p.id),
        );
      },
    );
  }

  Widget _buildRecommendationsList() {
    final cart = context.watch<CartProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _recommendations.map((p) => RecommendationProductCard(
          title: p.name,
          price: p.price.toStringAsFixed(0),
          rating: p.rating,
          imageUrl: p.primaryImage,
          onTap: () => _openProduct(p.id),
          onAddToCart: () => _addToCart(p.id),
          isInCart: cart.isInCart(p.id),
        )).toList(),
      ),
    );
  }

  Widget _buildContinueExploringList() {
    final List<Map<String, dynamic>> categories = [
      {'label': 'Mobiles', 'icon': Icons.smartphone_rounded, 'color': Colors.purple},
      {'label': 'Electronics', 'icon': Icons.laptop_rounded, 'color': Colors.blue},
      {'label': 'Fashion', 'icon': Icons.checkroom_rounded, 'color': Colors.green},
      {'label': 'Home', 'icon': Icons.chair_rounded, 'color': Colors.orange},
      {'label': 'Beauty', 'icon': Icons.face_rounded, 'color': Colors.pink},
      {'label': 'Accessories', 'icon': Icons.watch_rounded, 'color': Colors.deepPurple},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((c) => ContinueExploringCard(
          label: c['label'],
          icon: c['icon'],
          color: c['color'],
        )).toList(),
      ),
    );
  }
}
