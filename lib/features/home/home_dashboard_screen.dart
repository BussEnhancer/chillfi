import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/providers/product_provider.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/home/widgets/category_section.dart';
import 'package:chillfi/features/home/widgets/deal_section.dart';
import 'package:chillfi/features/home/widgets/hero_banner.dart';
import 'package:chillfi/features/home/widgets/home_header.dart';
import 'package:chillfi/features/home/widgets/home_search_bar.dart';
import 'package:chillfi/features/home/widgets/offer_cards.dart';
import 'package:chillfi/features/home/widgets/quick_features.dart';
import 'package:chillfi/features/new_arrivals/new_arrivals_screen.dart';
import 'package:chillfi/features/recommended/recommended_products_screen.dart';
import 'package:chillfi/features/trending/trending_products_screen.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load home data once on first visit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      if (p.homeState == LoadState.idle) p.loadHome();
      context.read<WishlistProvider>().fetchUnreadCount(); // bell badge (returns 0 for guests)
      // "Deliver to" header shows the customer's default address
      final cart = context.read<CartProvider>();
      cart.loadActiveCoupons(); // home offer card shows a real coupon
      if (context.read<AuthProvider>().isAuthenticated) {
        if (cart.selectedAddress == null) cart.loadAddresses();
        cart.loadCart(); // header cart badge
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeader(),
            const HomeSearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<ProductProvider>().loadHome(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      HeroBannerSlider(banners: context.watch<ProductProvider>().home.banners),
                      const QuickFeatureSection(),
                      const OfferCardsSection(),
                      const CategorySection(),
                      SizedBox(height: 15.h),
                      _DiscoverSection(),
                      SizedBox(height: 15.h),
                      const DealOfTheDaySection(),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }
}

class _DiscoverSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'label': 'New Arrivals',
        'icon': Icons.new_releases_rounded,
        'color': AppColors.secondaryPurple,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewArrivalsScreen())),
      },
      {
        'label': 'Trending',
        'icon': Icons.local_fire_department_rounded,
        'color': AppColors.primaryOrange,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrendingProductsScreen())),
      },
      {
        'label': 'For You',
        'icon': Icons.recommend_rounded,
        'color': AppColors.secondaryPurple,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommendedProductsScreen())),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: items.map((item) {
          final color = item['color'] as Color;
          return Expanded(
            child: GestureDetector(
              onTap: item['onTap'] as VoidCallback,
              child: Container(
                margin: EdgeInsets.only(right: item == items.last ? 0 : 10.w),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Icon(item['icon'] as IconData, color: color, size: 22.sp),
                    SizedBox(height: 6.h),
                    Text(
                      item['label'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
