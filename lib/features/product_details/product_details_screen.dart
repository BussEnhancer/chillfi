import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/categories/widgets/feature_highlights.dart';
import 'package:chillfi/features/product_details/product_reviews_screen.dart';
import 'package:chillfi/features/product_details/widgets/product_gallery.dart';
import 'package:chillfi/features/product_details/widgets/product_highlight_item.dart';
import 'package:chillfi/features/product_details/widgets/product_offer_card.dart';
import 'package:chillfi/features/product_details/widgets/similar_products_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedColorIndex = 0;
  int _selectedStorageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 24.sp),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.favorite_border_rounded, color: AppColors.darkText, size: 24.sp),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.shopping_cart_outlined, color: AppColors.darkText, size: 24.sp),
              ),
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProductGallery(),
                
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges
                      Row(
                        children: [
                          _buildBadge("-28% OFF", AppColors.secondaryPurple),
                          SizedBox(width: 8.w),
                          _buildBadge("Best Seller", Colors.orange),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      
                      // Title & Share
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Apple iPhone 15 (128GB)",
                              style: GoogleFonts.poppins(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.share_outlined, size: 20.sp, color: AppColors.darkText),
                          ),
                        ],
                      ),
                      
                      Text(
                        "Pink",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      
                      // Ratings
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProductReviewsScreen()),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.orange, size: 18.sp),
                            SizedBox(width: 4.w),
                            Text(
                              "4.5 (2.4k reviews)",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "10K+ Sold",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      
                      // Pricing
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "₹69,999",
                            style: GoogleFonts.poppins(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            "₹1,02,900",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: AppColors.greyText,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            "31% OFF",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      
                      // Savings Banner
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified_rounded, color: Colors.green, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              "You Save ₹32,901 on this product",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[800],
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded, color: Colors.green[800], size: 20.sp),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 30.h),
                      
                      // Offer Sections
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: const [
                            ProductOfferCard(
                              icon: Icons.credit_card_rounded,
                              title: "No Cost EMI",
                              subtitle: "From ₹5,834/m",
                            ),
                            ProductOfferCard(
                              icon: Icons.account_balance_rounded,
                              title: "Bank Offers",
                              subtitle: "Up to ₹7,000 Off",
                            ),
                            ProductOfferCard(
                              icon: Icons.swap_horizontal_circle_rounded,
                              title: "Exchange Offer",
                              subtitle: "Up to ₹10,000 Off",
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 30.h),
                      
                      // Color Selector
                      _buildSectionHeader("Color: Pink"),
                      SizedBox(height: 12.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: List.generate(5, (index) => _buildColorCard(index)),
                        ),
                      ),
                      
                      SizedBox(height: 30.h),
                      
                      // Storage Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader("Storage: 128GB"),
                          Text(
                            "Storage Guide",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryPurple,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          _buildStorageChip("128GB", 0),
                          _buildStorageChip("256GB", 1),
                          _buildStorageChip("512GB", 2),
                        ],
                      ),
                      
                      SizedBox(height: 30.h),
                      
                      // Product Highlights
                      _buildSectionHeader("Product Highlights", showViewAll: true),
                      SizedBox(height: 16.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: const [
                            ProductHighlightItem(
                              icon: Icons.screenshot_rounded,
                              title: "6.1\"",
                              subtitle: "Super Retina XDR Display",
                            ),
                            ProductHighlightItem(
                              icon: Icons.memory_rounded,
                              title: "A16 Bionic",
                              subtitle: "Industry-leading chip",
                            ),
                            ProductHighlightItem(
                              icon: Icons.camera_alt_rounded,
                              title: "48MP + 12MP",
                              subtitle: "Dual-camera system",
                            ),
                            ProductHighlightItem(
                              icon: Icons.battery_charging_full_rounded,
                              title: "20hrs",
                              subtitle: "Video Playback",
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 30.h),
                      
                      // Similar Products
                      const SimilarProductsSection(),
                      
                      SizedBox(height: 30.h),
                      
                      // Trust Bar (Reused)
                      const FeatureHighlightsRow(),
                      
                      SizedBox(height: 120.h), // Footer space
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Sticky Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showViewAll = false}) {
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

  Widget _buildColorCard(int index) {
    bool isSelected = _selectedColorIndex == index;
    List<String> labels = ["Pink", "Blue", "Black", "Green", "Yellow"];
    return GestureDetector(
      onTap: () => setState(() => _selectedColorIndex = index),
      child: Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.smartphone_rounded, color: Colors.grey[300], size: 40.sp),
            SizedBox(height: 4.h),
            Text(
              labels[index],
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.darkText : AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageChip(String label, int index) {
    bool isSelected = _selectedStorageIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedStorageIndex = index),
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.darkText,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 15.h, bottom: 25.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Row(
        children: [
          // Cart with badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shopping_cart_outlined, color: AppColors.darkText, size: 24.sp),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          // Add to Cart
          Expanded(
            child: Container(
              height: 54.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.secondaryPurple, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                "Add to Cart",
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryPurple,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Buy Now
          Expanded(
            child: Container(
              height: 54.h,
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.white, size: 18.sp),
                  SizedBox(width: 4.w),
                  Text(
                    "Buy Now",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
