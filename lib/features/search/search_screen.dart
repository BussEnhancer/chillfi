import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/search/widgets/custom_search_bar.dart';
import 'package:chillfi/features/search/widgets/help_banner_widget.dart';
import 'package:chillfi/features/search/widgets/popular_search_chip.dart';
import 'package:chillfi/features/search/widgets/search_chip_widget.dart';
import 'package:chillfi/features/search/widgets/suggested_product_card.dart';
import 'package:chillfi/features/search/widgets/trending_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomSearchHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    
                    // Recent Searches Section
                    _buildSectionHeader("Recent Searches", trailing: "Clear All"),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 10.h,
                      children: const [
                        SearchChipWidget(label: "iphone 15"),
                        SearchChipWidget(label: "macbook air"),
                        SearchChipWidget(label: "boat headphones"),
                        SearchChipWidget(label: "samsung s24"),
                        SearchChipWidget(label: "noise watch"),
                      ],
                    ),
                    
                    SizedBox(height: 30.h),
                    
                    // Popular Searches Section
                    _buildSectionHeader("Popular Searches"),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 12.h,
                      children: const [
                        PopularSearchChip(label: "Mobiles", icon: Icons.smartphone_rounded),
                        PopularSearchChip(label: "Laptops", icon: Icons.laptop_rounded),
                        PopularSearchChip(label: "Headphones", icon: Icons.headphones_rounded),
                        PopularSearchChip(label: "Smart Watch", icon: Icons.watch_rounded),
                        PopularSearchChip(label: "Cameras", icon: Icons.camera_alt_rounded),
                        PopularSearchChip(label: "Chargers", icon: Icons.power_rounded),
                        PopularSearchChip(label: "Speakers", icon: Icons.speaker_rounded),
                        PopularSearchChip(label: "More", icon: Icons.grid_view_rounded),
                      ],
                    ),
                    
                    SizedBox(height: 30.h),
                    
                    // Suggested Products Section
                    _buildSectionHeader("Suggested Products"),
                    SizedBox(height: 16.h),
                    const SuggestedProductCard(
                      title: "Apple iPhone 15 (128GB)",
                      variant: "Pink",
                      rating: 4.5,
                      reviewCount: "2.4k",
                      currentPrice: "69,999",
                      oldPrice: "79,900",
                      discount: "12%",
                      imageUrl: "",
                    ),
                    const SuggestedProductCard(
                      title: "Apple iPhone 15 (256GB)",
                      variant: "Black",
                      rating: 4.6,
                      reviewCount: "1.8k",
                      currentPrice: "79,999",
                      oldPrice: "89,900",
                      discount: "11%",
                      imageUrl: "",
                    ),
                    const SuggestedProductCard(
                      title: "Apple iPhone 15 Plus (128GB)",
                      variant: "Blue",
                      rating: 4.5,
                      reviewCount: "1.2k",
                      currentPrice: "79,999",
                      oldPrice: "89,900",
                      discount: "11%",
                      imageUrl: "",
                    ),
                    const SuggestedProductCard(
                      title: "Apple iPhone 15 Pro (128GB)",
                      variant: "Green",
                      rating: 4.7,
                      reviewCount: "980",
                      currentPrice: "1,19,999",
                      oldPrice: "1,34,900",
                      discount: "11%",
                      imageUrl: "",
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Help Banner
                    const HelpBannerWidget(),
                    
                    SizedBox(height: 30.h),
                    
                    // Trending Now Section
                    _buildSectionHeader("Trending Now"),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 12.h,
                      children: const [
                        TrendingChipWidget(label: "iphone 15 pro max"),
                        TrendingChipWidget(label: "airpods pro 2"),
                        TrendingChipWidget(label: "macbook pro m3"),
                        TrendingChipWidget(label: "samsung z fold 5"),
                      ],
                    ),
                    
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailing}) {
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
        if (trailing != null)
          GestureDetector(
            onTap: () {},
            child: Text(
              trailing,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryPurple,
              ),
            ),
          ),
      ],
    );
  }
}
