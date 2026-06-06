import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
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

class TrendingProductsScreen extends StatefulWidget {
  const TrendingProductsScreen({super.key});

  @override
  State<TrendingProductsScreen> createState() => _TrendingProductsScreenState();
}

class _TrendingProductsScreenState extends State<TrendingProductsScreen> {
  int _selectedChipIndex = 0;

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
              child: SingleChildScrollView(
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          TopTrendingCard(
            rank: 1,
            title: "Apple iPhone 15",
            variant: "Pink | 128GB",
            price: "69,999",
            oldPrice: "79,900",
            rating: 4.5,
            reviews: "2.4k",
          ),
          TopTrendingCard(
            rank: 2,
            title: "Sony WH-CH720N",
            variant: "Wireless Headphones",
            price: "5,999",
            oldPrice: "8,299",
            rating: 4.4,
            reviews: "1.2k",
          ),
          TopTrendingCard(
            rank: 3,
            title: "boAt Wave Elevate",
            variant: "Smart Watch",
            price: "1,799",
            oldPrice: "2,999",
            rating: 4.3,
            reviews: "980",
          ),
          TopTrendingCard(
            rank: 4,
            title: "HP 15s Laptop",
            variant: "i5 12th Gen",
            price: "45,990",
            oldPrice: "56,900",
            rating: 4.4,
            reviews: "760",
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTrendingGrid() {
    final List<Map<String, dynamic>> products = [
      {'title': 'Apple AirPods Pro', 'variant': '2nd Gen', 'price': '18,999', 'oldPrice': '24,900', 'discount': '24%', 'rating': 4.8, 'reviews': '1.5k'},
      {'title': 'Samsung Galaxy S23', 'variant': '256GB', 'price': '49,999', 'oldPrice': '64,999', 'discount': '22%', 'rating': 4.7, 'reviews': '1.2k'},
      {'title': 'Nike Air Max', 'variant': 'Men\'s Running', 'price': '4,549', 'oldPrice': '6,999', 'discount': '35%', 'rating': 4.5, 'reviews': '850'},
      {'title': 'Davidoff Cool Water', 'variant': 'Perfume 125ml', 'price': '2,399', 'oldPrice': '3,500', 'discount': '20%', 'rating': 4.3, 'reviews': '500'},
      {'title': 'boAt Stone 650', 'variant': 'Bluetooth Speaker', 'price': '2,299', 'oldPrice': '4,999', 'discount': '54%', 'rating': 4.4, 'reviews': '2.1k'},
      {'title': 'Canon EOS 200D II', 'variant': 'DSLR Camera', 'price': '39,999', 'oldPrice': '48,999', 'discount': '18%', 'rating': 4.6, 'reviews': '750'},
      {'title': 'Philips Hair Dryer', 'variant': 'HP8100/46', 'price': '1,199', 'oldPrice': '1,500', 'discount': '20%', 'rating': 4.3, 'reviews': '3.4k'},
      {'title': 'Noise ColorFit Pro 4', 'variant': 'Smart Watch', 'price': '2,999', 'oldPrice': '4,999', 'discount': '40%', 'rating': 4.2, 'reviews': '5.2k'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return MoreTrendingCard(
          title: p['title'],
          variant: p['variant'],
          price: p['price'],
          oldPrice: p['oldPrice'],
          discount: p['discount'],
          rating: p['rating'],
          reviews: p['reviews'],
        );
      },
    );
  }
}
