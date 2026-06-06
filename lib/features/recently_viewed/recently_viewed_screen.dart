import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/recently_viewed/widgets/continue_exploring_card.dart';
import 'package:chillfi/features/recently_viewed/widgets/recently_viewed_banner.dart';
import 'package:chillfi/features/recently_viewed/widgets/recently_viewed_header.dart';
import 'package:chillfi/features/recently_viewed/widgets/recently_viewed_product_card.dart';
import 'package:chillfi/features/recently_viewed/widgets/recommendation_product_card.dart';
import 'package:chillfi/features/recently_viewed/widgets/view_all_cta_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentlyViewedScreen extends StatefulWidget {
  const RecentlyViewedScreen({super.key});

  @override
  State<RecentlyViewedScreen> createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const RecentlyViewedHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    const RecentlyViewedBanner(),
                    SizedBox(height: 24.h),
                    
                    // Count and Clear All
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "8 Items",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Text(
                                "Clear All",
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFF5E5E),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.delete_outline_rounded, size: 18.sp, color: const Color(0xFFFF5E5E)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Recently Viewed Grid
                    _buildRecentlyViewedGrid(),
                    
                    SizedBox(height: 24.h),
                    const ViewAllRecentlyViewedCard(),
                    
                    SizedBox(height: 30.h),
                    _buildSectionHeader("Because you viewed"),
                    SizedBox(height: 16.h),
                    _buildRecommendationsList(),
                    
                    SizedBox(height: 30.h),
                    _buildSectionHeader("Continue Exploring", showViewAll: false),
                    SizedBox(height: 16.h),
                    _buildContinueExploringList(),
                    
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0), // Adjusting index if necessary
    );
  }

  Widget _buildSectionHeader(String title, {bool showViewAll = true}) {
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
        if (showViewAll)
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

  Widget _buildRecentlyViewedGrid() {
    final List<Map<String, dynamic>> products = [
      {'title': 'Apple iPhone 15', 'variant': '(128GB)', 'price': '69,999', 'rating': 4.5, 'reviews': '2.4k', 'time': 'Just now'},
      {'title': 'Sony WH-CH720N', 'variant': 'Wireless', 'price': '5,999', 'rating': 4.4, 'reviews': '1.2k', 'time': '5 mins ago'},
      {'title': 'boAt Wave Elevate', 'variant': 'Smart Watch', 'price': '1,799', 'rating': 4.3, 'reviews': '980', 'time': '15 mins ago'},
      {'title': 'HP 15s Laptop', 'variant': 'i5 12th Gen', 'price': '35,990', 'rating': 4.4, 'reviews': '760', 'time': '1 hour ago'},
      {'title': 'Apple AirPods Pro', 'variant': '(2nd Gen)', 'price': '18,999', 'rating': 4.8, 'reviews': '1.8k', 'time': '2 hours ago'},
      {'title': 'Davidoff Cool Water', 'variant': 'Perfume', 'price': '2,399', 'rating': 4.5, 'reviews': '980', 'time': '3 hours ago'},
      {'title': 'Nike Air Max', 'variant': 'Running Shoes', 'price': '4,549', 'rating': 4.3, 'reviews': '1.1k', 'time': 'Yesterday'},
      {'title': 'Lavie Women\'s', 'variant': 'Handbag', 'price': '1,299', 'rating': 4.4, 'reviews': '760', 'time': '2 days ago'},
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
        return RecentlyViewedProductCard(
          title: p['title'],
          variant: p['variant'],
          price: p['price'],
          rating: p['rating'],
          reviews: p['reviews'],
          timestamp: p['time'],
        );
      },
    );
  }

  Widget _buildRecommendationsList() {
    final List<Map<String, dynamic>> products = [
      {'title': 'Samsung Galaxy S23', 'price': '49,999', 'rating': 4.4},
      {'title': 'JBL Tune 770NC', 'price': '6,999', 'rating': 4.3},
      {'title': 'Noise ColorFit Pro 4', 'price': '2,999', 'rating': 4.3},
      {'title': 'Lenovo IdeaPad Slim 3', 'price': '42,990', 'rating': 4.4},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: products.map((p) => RecommendationProductCard(
          title: p['title'],
          price: p['price'],
          rating: p['rating'],
        )).toList(),
      ),
    );
  }

  Widget _buildContinueExploringList() {
    final List<Map<String, dynamic>> categories = [
      {'label': 'Mobiles', 'icon': Icons.smartphone_rounded, 'color': Colors.purple},
      {'label': 'Electronics', 'icon': Icons.laptop_rounded, 'color': Colors.blue},
      {'label': 'Fashion', 'icon': Icons.checkroom_rounded, 'color': Colors.green},
      {'label': 'Home', 'icon': Icons.chair_rounded, 'color': Colors.orange},
      {'label': 'Beauty', 'icon': Icons.face_rounded, 'color': Colors.pink},
      {'label': 'Accessories', 'icon': Icons.watch_rounded, 'color': Colors.deepPurple},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((c) => ContinueExploringCard(
          label: c['label'],
          icon: c['icon'],
          color: c['color'],
        )).toList(),
      ),
    );
  }
}
