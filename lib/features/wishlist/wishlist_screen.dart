import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/wishlist/widgets/wishlist_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Wishlist",
                        style: GoogleFonts.poppins(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        "Save your favorite items and shop them later.",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildActionIcon(Icons.search_rounded),
                      SizedBox(width: 12.w),
                      Stack(
                        children: [
                          _buildActionIcon(Icons.shopping_bag_outlined),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: const BoxDecoration(color: AppColors.secondaryPurple, shape: BoxShape.circle),
                              child: Text("3", style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              const WishlistSummaryCard(),
              SizedBox(height: 16.h),
              const SortFilterSection(),
              SizedBox(height: 24.h),
              
              const WishlistProductCard(
                name: "Fastrack Men Black Analog Watch",
                category: "Men's Watch",
                price: "2,495",
                stockStatus: "In Stock",
              ),
              const WishlistProductCard(
                name: "Puma Smashic Unisex Sneakers",
                category: "Size: 8  |  White",
                price: "2,999",
                stockStatus: "In Stock",
              ),
              const WishlistProductCard(
                name: "Lavie Women Green Satchel Bag",
                category: "Women's Bag",
                price: "1,799",
                stockStatus: "In Stock",
              ),
              const WishlistProductCard(
                name: "boAt Rockerz 450 Headphones",
                category: "Black",
                price: "1,499",
                stockStatus: "Only 2 Left",
                isLowStock: true,
              ),
              const WishlistProductCard(
                name: "Sukkhi Gold Plated Pendant Set",
                category: "Women's Jewellery",
                price: "699",
                stockStatus: "In Stock",
              ),
              const WishlistProductCard(
                name: "Wildcraft Laptop Backpack",
                category: "Navy Blue",
                price: "1,899",
                stockStatus: "In Stock",
              ),

              SizedBox(height: 8.h),
              const WishlistPromoCard(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Icon(icon, color: const Color(0xFF111827), size: 22.sp),
    );
  }
}
