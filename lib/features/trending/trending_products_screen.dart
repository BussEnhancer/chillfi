import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/product_model.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/core/services/product_service.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/product_details/product_details_screen.dart';
import 'package:chillfi/features/trending/widgets/feature_highlights_row.dart';
import 'package:chillfi/features/trending/widgets/more_trending_card.dart';
import 'package:chillfi/features/trending/widgets/top_trending_card.dart';
import 'package:chillfi/features/trending/widgets/trending_cta_banner.dart';
import 'package:chillfi/features/trending/widgets/trending_filter_chips.dart';
import 'package:chillfi/features/trending/widgets/trending_header.dart';
import 'package:chillfi/features/trending/widgets/trending_hero_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TrendingProductsScreen extends StatefulWidget {
  const TrendingProductsScreen({super.key});

  @override
  State<TrendingProductsScreen> createState() => _TrendingProductsScreenState();
}

class _TrendingProductsScreenState extends State<TrendingProductsScreen> {
  int _selectedChipIndex = 0;
  final _service = ProductService();
  List<ProductModel> _trending = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.getTrending(limit: 20);
    if (!mounted) return;
    setState(() { _trending = result; _loading = false; });
  }

  void _openProduct(String id) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: id)));
  }

  final List<Map<String, dynamic>> _filterChips = [
    {'label': 'All', 'icon': Icons.bolt_rounded},
    {'label': 'Mobiles', 'icon': Icons.smartphone_rounded},
    {'label': 'Electronics', 'icon': Icons.laptop_rounded},
    {'label': 'Fashion', 'icon': Icons.checkroom_rounded},
    {'label': 'Home', 'icon': Icons.home_rounded},
    {'label': 'Beauty', 'icon': Icons.face_rounded},
    {'label': 'Filter', 'icon': Icons.tune_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const TrendingHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          SizedBox(height: 10.h),
                          const TrendingHeroBanner(),
                          SizedBox(height: 20.h),
                          _buildFilterChips(),
                          SizedBox(height: 30.h),
                          _buildSectionHeader("Top Trending"),
                          SizedBox(height: 16.h),
                          _buildTopTrendingList(),
                          SizedBox(height: 30.h),
                          const TrendingCtaBanner(),
                          SizedBox(height: 30.h),
                          _buildSectionHeader("More Trending Products"),
                          SizedBox(height: 16.h),
                          _buildMoreTrendingGrid(),
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          _filterChips.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: TrendingFilterChip(
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

  Widget _buildTopTrendingList() {
    final top = _trending.take(4).toList();
    if (top.isEmpty) return const SizedBox.shrink();
    final wishlist = context.watch<WishlistProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(top.length, (i) {
          final p = top[i];
          return TopTrendingCard(
            rank: i + 1,
            title: p.name,
            variant: p.brandName ?? p.categoryName ?? '',
            price: p.price.toStringAsFixed(0),
            oldPrice: (p.oldPrice ?? p.price).toStringAsFixed(0),
            rating: p.rating,
            reviews: p.reviewCount > 999 ? '${(p.reviewCount / 1000).toStringAsFixed(1)}k' : '${p.reviewCount}',
            imageUrl: p.primaryImage,
            onTap: () => _openProduct(p.id),
            isWishlisted: wishlist.isWishlisted(p.id),
            onWishlistToggle: () => wishlist.toggleWishlist(p.id),
            onAddToCart: () => context.read<CartProvider>().addToCart(p.id),
          );
        }),
      ),
    );
  }

  Widget _buildMoreTrendingGrid() {
    final more = _trending.skip(4).toList();
    if (more.isEmpty) return const SizedBox.shrink();
    final wishlist = context.watch<WishlistProvider>();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: more.length,
      itemBuilder: (context, index) {
        final p = more[index];
        return MoreTrendingCard(
          title: p.name,
          variant: p.brandName ?? p.categoryName ?? '',
          price: p.price.toStringAsFixed(0),
          oldPrice: (p.oldPrice ?? p.price).toStringAsFixed(0),
          discount: '${p.discountPct}%',
          rating: p.rating,
          reviews: p.reviewCount > 999 ? '${(p.reviewCount / 1000).toStringAsFixed(1)}k' : '${p.reviewCount}',
          imageUrl: p.primaryImage,
          onTap: () => _openProduct(p.id),
          isWishlisted: wishlist.isWishlisted(p.id),
          onWishlistToggle: () => wishlist.toggleWishlist(p.id),
          onAddToCart: () => context.read<CartProvider>().addToCart(p.id),
        );
      },
    );
  }
}
