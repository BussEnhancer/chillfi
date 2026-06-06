import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/categories/widgets/feature_highlights.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/product_listing/widgets/bottom_action_bar.dart';
import 'package:chillfi/features/product_listing/widgets/category_filter_chips.dart';
import 'package:chillfi/features/product_listing/widgets/product_card.dart';
import 'package:chillfi/features/product_listing/widgets/product_listing_header.dart';
import 'package:chillfi/features/product_listing/widgets/product_listing_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  int _selectedChipIndex = 0;

  final List<Map<String, dynamic>> _filterChips = [
    {'label': 'All', 'icon': Icons.grid_view_rounded},
    {'label': 'Smartphones', 'icon': Icons.smartphone_rounded},
    {'label': 'Tablets', 'icon': Icons.tablet_rounded},
    {'label': 'Feature Phones', 'icon': Icons.phone_android_rounded},
    {'label': 'Filter', 'icon': Icons.tune_rounded},
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'title': 'Apple iPhone 15',
      'variant': 'Pink | 128GB',
      'price': '69,999',
      'oldPrice': '1,02,900',
      'discount': '32%',
      'savings': '32,901',
      'rating': 4.5,
      'reviews': '2.4k',
    },
    {
      'title': 'Samsung Galaxy S23',
      'variant': 'Phantom Black | 256GB',
      'price': '49,999',
      'oldPrice': '63,999',
      'discount': '22%',
      'savings': '14,000',
      'rating': 4.4,
      'reviews': '2.1k',
    },
    {
      'title': 'Apple AirPods Pro',
      'variant': 'White | 2nd Gen',
      'price': '18,999',
      'oldPrice': '26,999',
      'discount': '30%',
      'savings': '8,000',
      'rating': 4.6,
      'reviews': '1.8k',
    },
    {
      'title': 'Sony WH-CH720N',
      'variant': 'Wireless Headphones',
      'price': '5,999',
      'oldPrice': '9,999',
      'discount': '40%',
      'savings': '4,000',
      'rating': 4.4,
      'reviews': '1.2k',
    },
    {
      'title': 'boAt Wave Elevate',
      'variant': 'Smart Watch',
      'price': '1,799',
      'oldPrice': '2,999',
      'discount': '40%',
      'savings': '1,200',
      'rating': 4.3,
      'reviews': '980',
    },
    {
      'title': 'HP 15s Laptop',
      'variant': 'i5 12th Gen | 8GB/512GB',
      'price': '35,990',
      'oldPrice': '47,990',
      'discount': '25%',
      'savings': '12,000',
      'rating': 4.4,
      'reviews': '760',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                const ProductListingHeader(
                  title: "Mobiles & Tablets",
                  productCount: "2,356 Products",
                ),
                const ProductListingSearch(),
                SizedBox(height: 12.h),
                _buildFilterChips(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),
                        // Count and Sort Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "2,356 Products",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Sort by: ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: AppColors.greyText,
                                  ),
                                ),
                                Text(
                                  "Popular",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondaryPurple,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded, size: 16.sp, color: AppColors.secondaryPurple),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        // Benefit Strip (Reused)
                        const FeatureHighlightsRow(),
                        SizedBox(height: 20.h),
                        // Product Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 15.h,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final p = _products[index];
                            return ProductListingCard(
                              title: p['title'],
                              variant: p['variant'],
                              price: p['price'],
                              oldPrice: p['oldPrice'],
                              discount: p['discount'],
                              savings: p['savings'],
                              rating: p['rating'],
                              reviews: p['reviews'],
                            );
                          },
                        ),
                        SizedBox(height: 100.h), // Space for floating bar
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Floating Bottom Toolbar
            Positioned(
              bottom: 20.h,
              child: const BottomActionBar(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(
          _filterChips.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: CategoryFilterChip(
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
}
