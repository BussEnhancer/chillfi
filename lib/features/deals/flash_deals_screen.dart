import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/product_model.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/core/services/product_service.dart';
import 'package:chillfi/features/deals/widgets/deal_category_chip.dart';
import 'package:chillfi/features/deals/widgets/deal_feature_highlight.dart';
import 'package:chillfi/features/deals/widgets/deal_product_card.dart';
import 'package:chillfi/features/deals/widgets/flash_banner.dart';
import 'package:chillfi/features/deals/widgets/flash_header.dart';
import 'package:chillfi/features/deals/widgets/notify_card.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/product_details/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FlashDealsScreen extends StatefulWidget {
  const FlashDealsScreen({super.key});

  @override
  State<FlashDealsScreen> createState() => _FlashDealsScreenState();
}

class _FlashDealsScreenState extends State<FlashDealsScreen> {
  int _selectedChipIndex = 0;
  final _service = ProductService();
  List<ProductModel> _deals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.getFlashSale(limit: 20);
    if (!mounted) return;
    setState(() { _deals = result; _loading = false; });
  }

  void _openProduct(String id) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: id)));
  }

  final List<Map<String, dynamic>> _filterChips = [
    {'label': 'All Deals', 'icon': Icons.bolt_rounded, 'filter': null},
    {'label': 'Mobiles', 'icon': Icons.smartphone_rounded, 'filter': 'Mobiles'},
    {'label': 'Electronics', 'icon': Icons.laptop_rounded, 'filter': 'Electronics'},
    {'label': 'Home', 'icon': Icons.home_rounded, 'filter': 'Home'},
    {'label': 'Fashion', 'icon': Icons.checkroom_rounded, 'filter': 'Fashion'},
    {'label': 'Beauty', 'icon': Icons.face_rounded, 'filter': 'Beauty'},
  ];

  List<ProductModel> get _filteredDeals {
    final filter = _filterChips[_selectedChipIndex]['filter'] as String?;
    if (filter == null) return _deals;
    return _deals.where((p) => (p.categoryName ?? '').toLowerCase().contains(filter.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const FlashHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          SizedBox(height: 10.h),
                          const FlashBanner(),
                          SizedBox(height: 20.h),
                          _buildFilterChips(),
                          SizedBox(height: 24.h),
                          const DealFeatureHighlight(),
                          SizedBox(height: 30.h),
                          _buildSectionHeader("Top Deals"),
                          SizedBox(height: 16.h),
                          _buildTopDeals(),
                          SizedBox(height: 30.h),
                          _buildSectionHeader("Deals Under ₹999"),
                          SizedBox(height: 16.h),
                          _buildDealsUnder999(),
                          SizedBox(height: 30.h),
                          const NotifyCard(),
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
            child: DealCategoryChip(
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

  Widget _buildTopDeals() {
    final deals = _filteredDeals;
    if (deals.isEmpty) return const SizedBox.shrink();
    final wishlist = context.watch<WishlistProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: deals.map((p) => DealProductCard(
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
        )).toList(),
      ),
    );
  }

  Widget _buildDealsUnder999() {
    final under999 = _filteredDeals.where((p) => p.price < 999).toList();
    if (under999.isEmpty) return const SizedBox.shrink();
    final wishlist = context.watch<WishlistProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: under999.map((p) => DealProductCard(
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
        )).toList(),
      ),
    );
  }
}
