import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/brands/widgets/brand_banner.dart';
import 'package:chillfi/features/brands/widgets/brand_card.dart';
import 'package:chillfi/features/brands/widgets/brand_chip.dart';
import 'package:chillfi/features/brands/widgets/brand_header.dart';
import 'package:chillfi/features/brands/widgets/bottom_offer_widget.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandListingScreen extends StatefulWidget {
  const BrandListingScreen({super.key});

  @override
  State<BrandListingScreen> createState() => _BrandListingScreenState();
}

class _BrandListingScreenState extends State<BrandListingScreen> {
  int _selectedChipIndex = 0;

  final List<Map<String, dynamic>> _filterChips = [
    {'label': 'All Brands', 'icon': Icons.grid_view_rounded},
    {'label': 'Popular', 'icon': Icons.star_rounded},
    {'label': 'Electronics', 'icon': Icons.smartphone_rounded},
    {'label': 'Fashion', 'icon': Icons.checkroom_rounded},
    {'label': 'Home', 'icon': Icons.home_rounded},
    {'label': 'Filter', 'icon': Icons.tune_rounded},
  ];

  final List<Map<String, dynamic>> _brands = [
    {'name': 'Apple', 'logo': Icons.apple_rounded, 'count': '1,256 Products'},
    {'name': 'Samsung', 'logo': Icons.smartphone_rounded, 'count': '2,458 Products'},
    {'name': 'Xiaomi', 'logo': Icons.phone_android_rounded, 'count': '1,876 Products'},
    {'name': 'OnePlus', 'logo': Icons.phone_iphone_rounded, 'count': '742 Products'},
    {'name': 'realme', 'logo': Icons.mobile_friendly_rounded, 'count': '1,234 Products'},
    {'name': 'boAt', 'logo': Icons.headset_rounded, 'count': '956 Products'},
    {'name': 'Sony', 'logo': Icons.speaker_rounded, 'count': '1,102 Products'},
    {'name': 'JBL', 'logo': Icons.audiotrack_rounded, 'count': '684 Products'},
    {'name': 'HP', 'logo': Icons.laptop_rounded, 'count': '1,123 Products'},
    {'name': 'Dell', 'logo': Icons.laptop_mac_rounded, 'count': '896 Products'},
    {'name': 'Lenovo', 'logo': Icons.laptop_windows_rounded, 'count': '1,045 Products'},
    {'name': 'ASUS', 'logo': Icons.computer_rounded, 'count': '732 Products'},
    {'name': 'Nike', 'logo': Icons.directions_run_rounded, 'count': '1,567 Products'},
    {'name': 'Adidas', 'logo': Icons.sports_rounded, 'count': '1,234 Products'},
    {'name': 'Puma', 'logo': Icons.pets_rounded, 'count': '876 Products'},
    {'name': 'Fastrack', 'logo': Icons.watch_rounded, 'count': '542 Products'},
    {'name': 'Philips', 'logo': Icons.lightbulb_rounded, 'count': '768 Products'},
    {'name': 'LG', 'logo': Icons.tv_rounded, 'count': '1,032 Products'},
    {'name': 'Dyson', 'logo': Icons.air_rounded, 'count': '456 Products'},
    {'name': 'Panasonic', 'logo': Icons.microwave_rounded, 'count': '684 Products'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BrandHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    
                    // Search Bar
                    _buildSearchBar(),
                    
                    SizedBox(height: 20.h),
                    
                    // Filter Chips
                    _buildFilterChips(),
                    
                    SizedBox(height: 20.h),
                    
                    // Banner
                    const BrandBanner(),
                    
                    SizedBox(height: 24.h),
                    
                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                            children: [
                              const TextSpan(text: "All Brands "),
                              TextSpan(
                                text: "(248)",
                                style: TextStyle(
                                  color: AppColors.greyText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
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
                    
                    // Brands Grid
                    _buildBrandsGrid(),
                    
                    SizedBox(height: 24.h),
                    
                    // Bottom Offer Card
                    const BottomOfferWidget(),
                    
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.greyText, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search brands...",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: AppColors.greyText.withOpacity(0.6),
                ),
                border: InputBorder.none,
              ),
            ),
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
            child: BrandChip(
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

  Widget _buildBrandsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: _brands.length,
      itemBuilder: (context, index) {
        return BrandCard(
          name: _brands[index]['name'],
          logo: _brands[index]['logo'],
          productCount: _brands[index]['count'],
        );
      },
    );
  }
}
