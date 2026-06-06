import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/deals/widgets/deal_category_chip.dart';
import 'package:chillfi/features/deals/widgets/deal_feature_highlight.dart';
import 'package:chillfi/features/deals/widgets/deal_product_card.dart';
import 'package:chillfi/features/deals/widgets/flash_banner.dart';
import 'package:chillfi/features/deals/widgets/flash_header.dart';
import 'package:chillfi/features/deals/widgets/notify_card.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FlashDealsScreen extends StatefulWidget {
  const FlashDealsScreen({super.key});

  @override
  State<FlashDealsScreen> createState() => _FlashDealsScreenState();
}

class _FlashDealsScreenState extends State<FlashDealsScreen> {
  int _selectedChipIndex = 0;

  final List<Map<String, dynamic>> _filterChips = [
    {'label': 'All Deals', 'icon': Icons.bolt_rounded},
    {'label': 'Mobiles', 'icon': Icons.smartphone_rounded},
    {'label': 'Electronics', 'icon': Icons.laptop_rounded},
    {'label': 'Home', 'icon': Icons.home_rounded},
    {'label': 'Fashion', 'icon': Icons.checkroom_rounded},
    {'label': 'Beauty', 'icon': Icons.face_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const FlashHeader(),
            Expanded(
              child: SingleChildScrollView(
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          DealProductCard(
            title: "Apple iPhone 15",
            variant: "Pink | 128GB",
            price: "69,999",
            oldPrice: "79,900",
            discount: "32%",
            rating: 4.5,
            reviews: "2.4k",
          ),
          DealProductCard(
            title: "Sony WH-CH720N",
            variant: "Wireless Headphones",
            price: "5,999",
            oldPrice: "8,299",
            discount: "28%",
            rating: 4.4,
            reviews: "1.2k",
          ),
          DealProductCard(
            title: "boAt Wave Elevate",
            variant: "Smart Watch",
            price: "1,799",
            oldPrice: "2,999",
            discount: "40%",
            rating: 4.3,
            reviews: "980",
          ),
        ],
      ),
    );
  }

  Widget _buildDealsUnder999() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          DealProductCard(
            title: "Ambrane Type C",
            variant: "1M Cable",
            price: "249",
            oldPrice: "499",
            discount: "50%",
            rating: 4.5,
            reviews: "8k",
          ),
          DealProductCard(
            title: "Zebronics Wired",
            variant: "Earphones",
            price: "219",
            oldPrice: "399",
            discount: "45%",
            rating: 4.2,
            reviews: "3k",
          ),
          DealProductCard(
            title: "Portronics Smart",
            variant: "Plug 16A",
            price: "599",
            oldPrice: "999",
            discount: "40%",
            rating: 4.4,
            reviews: "5k",
          ),
        ],
      ),
    );
  }
}
