import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrivals_filter_chips.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrivals_feature_highlights.dart';
import 'package:chillfi/features/offers/widgets/bank_offer_banner.dart';
import 'package:chillfi/features/offers/widgets/offer_benefit_card.dart';
import 'package:chillfi/features/offers/widgets/offer_product_card.dart';
import 'package:chillfi/features/offers/widgets/offers_header.dart';
import 'package:chillfi/features/offers/widgets/offers_hero_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OffersProductsScreen extends StatefulWidget {
  const OffersProductsScreen({super.key});

  @override
  State<OffersProductsScreen> createState() => _OffersProductsScreenState();
}

class _OffersProductsScreenState extends State<OffersProductsScreen> {
  int _selectedChipIndex = 0;

  final List<Map<String, dynamic>> _filterChips = [
    {'label': 'All Offers', 'icon': Icons.local_offer_rounded},
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
            const OffersHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    const OffersHeroBanner(),
                    SizedBox(height: 20.h),
                    _buildFilterChips(),
                    SizedBox(height: 24.h),
                    _buildBenefitsRow(),
                    SizedBox(height: 30.h),
                    _buildSectionHeader("Top Offers"),
                    SizedBox(height: 16.h),
                    _buildTopOffersList(),
                    SizedBox(height: 30.h),
                    _buildSectionHeader("More Offers"),
                    SizedBox(height: 16.h),
                    _buildMoreOffersList(),
                    SizedBox(height: 30.h),
                    const BankOfferBanner(),
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

  Widget _buildBenefitsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          OfferBenefitCard(
            icon: Icons.account_balance_rounded,
            title: "Bank Offers",
            subtitle: "Up to 10% Off",
            color: Colors.orange,
          ),
          OfferBenefitCard(
            icon: Icons.credit_card_rounded,
            title: "No Cost EMI",
            subtitle: "Up to 12 Months",
            color: Colors.purple,
          ),
          OfferBenefitCard(
            icon: Icons.swap_horizontal_circle_rounded,
            title: "Exchange Offer",
            subtitle: "Up to ₹10,000 Off",
            color: Colors.blue,
          ),
          OfferBenefitCard(
            icon: Icons.local_shipping_rounded,
            title: "Free Delivery",
            subtitle: "On Prepaid Orders",
            color: Colors.green,
          ),
        ],
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

  Widget _buildTopOffersList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          OfferProductCard(
            title: "Apple iPhone 15",
            variant: "Pink | 128GB",
            price: "69,999",
            oldPrice: "1,02,900",
            discount: "32%",
            savings: "32,901",
            rating: 4.5,
            reviews: "2.4k",
          ),
          OfferProductCard(
            title: "Sony WH-CH720N",
            variant: "Wireless Headphones",
            price: "5,999",
            oldPrice: "8,299",
            discount: "28%",
            savings: "2,300",
            rating: 4.4,
            reviews: "1.2k",
          ),
          OfferProductCard(
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

  Widget _buildMoreOffersList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          OfferProductCard(
            title: "Apple AirPods Pro",
            variant: "2nd Gen",
            price: "18,999",
            oldPrice: "26,999",
            discount: "30%",
            savings: "8,000",
            rating: 4.6,
            reviews: "1.8k",
          ),
          OfferProductCard(
            title: "Samsung Galaxy S23",
            variant: "256GB",
            price: "49,999",
            oldPrice: "63,999",
            discount: "22%",
            savings: "14,000",
            rating: 4.4,
            reviews: "2.5k",
          ),
          OfferProductCard(
            title: "Davidoff Cool Water",
            variant: "Perfume (125ml)",
            price: "2,399",
            oldPrice: "2,999",
            discount: "20%",
            savings: "600",
            rating: 4.2,
            reviews: "980",
            hasOfferRibbon: true,
          ),
        ],
      ),
    );
  }
}
