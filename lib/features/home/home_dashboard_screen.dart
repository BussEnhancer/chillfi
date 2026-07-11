import 'package:chillfi/core/providers/product_provider.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/home/widgets/category_section.dart';
import 'package:chillfi/features/home/widgets/deal_section.dart';
import 'package:chillfi/features/home/widgets/hero_banner.dart';
import 'package:chillfi/features/home/widgets/home_header.dart';
import 'package:chillfi/features/home/widgets/home_search_bar.dart';
import 'package:chillfi/features/home/widgets/offer_cards.dart';
import 'package:chillfi/features/home/widgets/quick_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
