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

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header and Search Bar
            const HomeHeader(),
            const HomeSearchBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const HeroBannerSlider(),
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
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }
}
