import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrivals_filter_chips.dart';
import 'package:chillfi/features/recommended/widgets/explanation_banner.dart';
import 'package:chillfi/features/recommended/widgets/recommended_benefit_card.dart';
import 'package:chillfi/features/recommended/widgets/recommended_header.dart';
import 'package:chillfi/features/recommended/widgets/recommended_hero_banner.dart';
import 'package:chillfi/features/recommended/widgets/recommended_product_card.dart';
import 'package:chillfi/features/trending/widgets/feature_highlights_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendedProductsScreen extends StatefulWidget {
  const RecommendedProductsScreen({super.key});

  @override
  State<RecommendedProductsScreen> createState() => _RecommendedProductsScreenState();
}

class _RecommendedProductsScreenState extends State<RecommendedProductsScreen> {
  int _selectedChipIndex = 0;

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
              child: SingleChildScrollView(
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          RecommendedProductCard(
            title: "Apple iPhone 15",
            variant: "Pink | 128GB",
            price: "69,999",
            oldPrice: "1,02,900",
            discount: "32%",
            savings: "32,901",
            rating: 4.5,
            reviews: "2.4k",
          ),
          RecommendedProductCard(
            title: "Sony WH-CH720N",
            variant: "Wireless Headphones",
            price: "5,999",
            oldPrice: "8,299",
            discount: "28%",
            savings: "2,300",
            rating: 4.4,
            reviews: "1.2k",
          ),
          RecommendedProductCard(
            title: "boAt Wave Elevate",
            variant: "Smart Watch",
            price: "1,799",
            oldPrice: "2,999",
            discount: "40%",
            savings: "1,200",
            rating: 4.3,
            reviews: "980",
          ),
        ],
      ),
    );
  }

  Widget _buildMoreRecommendationsList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          RecommendedProductCard(
            title: "Apple AirPods Pro",
            variant: "2nd Gen",
            price: "18,999",
            oldPrice: "26,999",
            discount: "30%",
            savings: "8,000",
            rating: 4.6,
            reviews: "1.8k",
          ),
          RecommendedProductCard(
            title: "Samsung Galaxy S23",
            variant: "256GB",
            price: "49,999",
            oldPrice: "63,999",
            discount: "22%",
            savings: "14,000",
            rating: 4.4,
            reviews: "2.5k",
          ),
          RecommendedProductCard(
            title: "Nike Air Max",
            variant: "Running Shoes",
            price: "4,549",
            oldPrice: "6,999",
            discount: "35%",
            savings: "2,450",
            rating: 4.3,
            reviews: "1.1k",
          ),
        ],
      ),
    );
  }
}
