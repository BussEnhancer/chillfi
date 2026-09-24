import 'package:chillfi/core/widgets/cart_feedback.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/product_model.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/core/services/product_service.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrivals_filter_chips.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrivals_feature_highlights.dart';
import 'package:chillfi/features/offers/widgets/offer_product_card.dart';
import 'package:chillfi/features/offers/widgets/offers_header.dart';
import 'package:chillfi/features/offers/widgets/offers_hero_banner.dart';
import 'package:chillfi/features/product_details/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OffersProductsScreen extends StatefulWidget {
  const OffersProductsScreen({super.key});

  @override
  State<OffersProductsScreen> createState() => _OffersProductsScreenState();
}

class _OffersProductsScreenState extends State<OffersProductsScreen> {
  int _selectedChipIndex = 0;
  final _service = ProductService();
  List<ProductModel> _offers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.getFeatured(limit: 20);
    if (!mounted) return;
    setState(() { _offers = result.where((p) => p.discountPct > 0).toList(); _loading = false; });
  }

  void _openProduct(String id) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: id)));
  }

  // Chips = the real categories present in this list (no invented categories).
  List<Map<String, dynamic>> get _filterChips => [
        {'label': 'All', 'icon': Icons.grid_view_rounded},
        ...{for (final p in _offers) if ((p.categoryName ?? '').isNotEmpty) p.categoryName!}
            .map((c) => {'label': c, 'icon': Icons.category_outlined}),
      ];

  List<ProductModel> get _visible => _selectedChipIndex == 0 || _selectedChipIndex >= _filterChips.length
      ? _offers
      : _offers.where((p) => p.categoryName == _filterChips[_selectedChipIndex]['label']).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const OffersHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          SizedBox(height: 10.h),
                          const OffersHeroBanner(),
                          SizedBox(height: 20.h),
                          _buildFilterChips(),
                          SizedBox(height: 24.h),
                          _buildSectionHeader("Top Offers"),
                          SizedBox(height: 16.h),
                          _buildTopOffersList(),
                          SizedBox(height: 30.h),
                          _buildSectionHeader("More Offers"),
                          SizedBox(height: 16.h),
                          _buildMoreOffersList(),
                          SizedBox(height: 30.h),
                          const NewArrivalsFeatureHighlights(), // Reusing trust highlights
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
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
      ],
    );
  }

  Widget _buildTopOffersList() {
    final top = _visible.take(3).toList();
    if (top.isEmpty) return const SizedBox.shrink();
    final wishlist = context.watch<WishlistProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: top.map((p) => OfferProductCard(
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

  Widget _buildMoreOffersList() {
    final more = _visible.skip(3).toList();
    if (more.isEmpty) return const SizedBox.shrink();
    final wishlist = context.watch<WishlistProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: more.map((p) => OfferProductCard(
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
