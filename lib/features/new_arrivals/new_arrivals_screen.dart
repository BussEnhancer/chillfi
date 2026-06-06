import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrival_product_card.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrivals_category_item.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrivals_feature_highlights.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrivals_filter_chips.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrivals_header.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrivals_hero_banner.dart';
import 'package:chillfi/features/new_arrivals/widgets/new_arrivals_notify_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NewArrivalsScreen extends StatefulWidget {
  const NewArrivalsScreen({super.key});

  @override
  State<NewArrivalsScreen> createState() => _NewArrivalsScreenState();
}

class _NewArrivalsScreenState extends State<NewArrivalsScreen> {
  int _selectedChipIndex = 0;

  final List<Map<String, dynamic>> _filterChips = [
    {'label': 'All', 'icon': Icons.grid_view_rounded},
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
            const NewArrivalsHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    const NewArrivalsHeroBanner(),
                    SizedBox(height: 20.h),
                    _buildFilterChips(),
                    SizedBox(height: 24.h),
                    const NewArrivalsFeatureHighlights(),
                    SizedBox(height: 30.h),
                    _buildSectionHeader("New Arrivals"),
                    SizedBox(height: 16.h),
                    _buildNewArrivalsGrid(),
                    SizedBox(height: 30.h),
                    const NewArrivalsNotifyBanner(),
                    SizedBox(height: 30.h),
                    _buildSectionHeader("Shop by Category"),
                    SizedBox(height: 16.h),
                    _buildCategoryRow(),
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

  Widget _buildNewArrivalsGrid() {
    final List<Map<String, dynamic>> products = [
      {'title': 'Apple iPhone 15', 'variant': '(128GB)', 'price': '69,999', 'rating': 4.5, 'reviews': '2.4k'},
      {'title': 'MacBook Air M2', 'variant': '(8GB/256GB)', 'price': '89,990', 'rating': 4.6, 'reviews': '1.2k'},
      {'title': 'boAt Wave Elevate', 'variant': 'Smart Watch', 'price': '1,799', 'rating': 4.3, 'reviews': '980'},
      {'title': 'Apple AirPods Pro', 'variant': '(2nd Gen)', 'price': '18,999', 'rating': 4.8, 'reviews': '1.5k'},
      {'title': 'Nike Air Max', 'variant': 'Running Shoes', 'price': '4,549', 'rating': 4.4, 'reviews': '1.1k'},
      {'title': 'Davidoff Cool Water', 'variant': 'Eau De Toilette', 'price': '2,399', 'rating': 4.5, 'reviews': '580'},
      {'title': 'Lavie Women\'s', 'variant': 'Handbag', 'price': '1,299', 'rating': 4.4, 'reviews': '760'},
      {'title': 'Sony WH-1000XM5', 'variant': 'Headphones', 'price': '22,990', 'rating': 4.5, 'reviews': '890'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return NewArrivalProductCard(
          title: p['title'],
          variant: p['variant'],
          price: p['price'],
          rating: p['rating'],
          reviews: p['reviews'],
        );
      },
    );
  }

  Widget _buildCategoryRow() {
    final List<Map<String, dynamic>> categories = [
      {'label': 'Mobiles', 'icon': Icons.smartphone_rounded},
      {'label': 'Electronics', 'icon': Icons.laptop_rounded},
      {'label': 'Fashion', 'icon': Icons.checkroom_rounded},
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Beauty', 'icon': Icons.face_rounded},
      {'label': 'Accessories', 'icon': Icons.headset_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((c) => NewArrivalsCategoryItem(label: c['label'], icon: c['icon'])).toList(),
      ),
    );
  }
}
