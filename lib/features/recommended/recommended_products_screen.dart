import 'package:chillfi/core/widgets/cart_feedback.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/product_model.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/core/services/product_service.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrivals_filter_chips.dart';
import 'package:chillfi/features/product_details/product_details_screen.dart';
import 'package:chillfi/features/recommended/widgets/explanation_banner.dart';
import 'package:chillfi/features/recommended/widgets/recommended_benefit_card.dart';
import 'package:chillfi/features/recommended/widgets/recommended_header.dart';
import 'package:chillfi/features/recommended/widgets/recommended_hero_banner.dart';
import 'package:chillfi/features/recommended/widgets/recommended_product_card.dart';
import 'package:chillfi/features/trending/widgets/feature_highlights_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RecommendedProductsScreen extends StatefulWidget {
  const RecommendedProductsScreen({super.key});

  @override
  State<RecommendedProductsScreen> createState() => _RecommendedProductsScreenState();
}

class _RecommendedProductsScreenState extends State<RecommendedProductsScreen> {
  int _selectedChipIndex = 0;
  final _service = ProductService();
  List<ProductModel> _recommended = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.getRecommended(limit: 20);
    if (!mounted) return;
    setState(() { _recommended = result; _loading = false; });
  }

  void _openProduct(String id) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: id)));
  }

  final List<Map<String, dynamic>> _filterChips = [
    {'label': 'All Recommendations', 'icon': Icons.stars_rounded},
    {'label': 'Mobiles', 'icon': Icons.smartphone_rounded},
    {'label': 'Electronics', 'icon': Icons.laptop_rounded},
    {'label': 'Fashion', 'icon': Icons.checkroom_rounded},
    {'label': 'Home', 'icon': Icons.home_rounded},
    {'label': 'Beauty', 'icon': Icons.face_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const RecommendedHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          SizedBox(height: 10.h),
                          const RecommendedHeroBanner(),
                          SizedBox(height: 20.h),
                          _buildBenefitsRow(),
                          SizedBox(height: 24.h),
                          _buildFilterChips(),
                          SizedBox(height: 30.h),
                          _buildSectionHeader("Top Picks for You"),
                          SizedBox(height: 16.h),
                          _buildTopPicksList(),
                          SizedBox(height: 30.h),
                          _buildSectionHeader("More Recommendations"),
                          SizedBox(height: 16.h),
                          _buildMoreRecommendationsList(),
                          SizedBox(height: 30.h),
                          const ExplanationBanner(),
                          SizedBox(height: 30.h),
                          const FeatureHighlightsRow(),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 2),
    );
  }

  Widget _buildBenefitsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          RecommendedBenefitCard(
            icon: Icons.thumb_up_rounded,
            title: "Handpicked",
            subtitle: "Just for you",
            color: Colors.purple,
          ),
          RecommendedBenefitCard(
            icon: Icons.verified_user_rounded,
            title: "100% Original",
            subtitle: "Genuine Products",
            color: Colors.green,
          ),
          RecommendedBenefitCard(
            icon: Icons.local_offer_rounded,
            title: "Great Prices",
            subtitle: "Best Value Deals",
            color: Colors.orange,
          ),
          RecommendedBenefitCard(
            icon: Icons.sync_rounded,
            title: "Easy Returns",
            subtitle: "Hassle Free",
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          _filterChips.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: NewArrivalsFilterChip(
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

  Widget _buildSectionHeader(String title) {
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

  Widget _buildTopPicksList() {
    final top = _recommended.take(3).toList();
    if (top.isEmpty) return const SizedBox.shrink();
    final wishlist = context.watch<WishlistProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: top.map((p) => RecommendedProductCard(
          title: p.name,
          variant: p.brandName ?? p.categoryName ?? '',
          price: p.price.toStringAsFixed(0),
          oldPrice: (p.oldPrice ?? p.price).toStringAsFixed(0),
          discount: '${p.discountPct}%',
          savings: ((p.oldPrice ?? p.price) - p.price).toStringAsFixed(0),
          rating: p.rating,
          reviews: p.reviewCount > 999 ? '${(p.reviewCount / 1000).toStringAsFixed(1)}k' : '${p.reviewCount}',
          imageUrl: p.primaryImage,
          onTap: () => _openProduct(p.id),
          isWishlisted: wishlist.isWishlisted(p.id),
          onWishlistToggle: () => wishlist.toggleWishlist(p.id),
          onAddToCart: () => addToCartWithFeedback(context, p.id, productName: p.name),
        )).toList(),
      ),
    );
  }

  Widget _buildMoreRecommendationsList() {
    final more = _recommended.skip(3).toList();
    if (more.isEmpty) return const SizedBox.shrink();
    final wishlist = context.watch<WishlistProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: more.map((p) => RecommendedProductCard(
          title: p.name,
          variant: p.brandName ?? p.categoryName ?? '',
          price: p.price.toStringAsFixed(0),
          oldPrice: (p.oldPrice ?? p.price).toStringAsFixed(0),
          discount: '${p.discountPct}%',
          savings: ((p.oldPrice ?? p.price) - p.price).toStringAsFixed(0),
          rating: p.rating,
          reviews: p.reviewCount > 999 ? '${(p.reviewCount / 1000).toStringAsFixed(1)}k' : '${p.reviewCount}',
          imageUrl: p.primaryImage,
          onTap: () => _openProduct(p.id),
          isWishlisted: wishlist.isWishlisted(p.id),
          onWishlistToggle: () => wishlist.toggleWishlist(p.id),
          onAddToCart: () => addToCartWithFeedback(context, p.id, productName: p.name),
        )).toList(),
      ),
    );
  }
}
