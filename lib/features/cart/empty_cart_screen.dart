import 'package:chillfi/features/cart/widgets/empty_cart_widgets.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyCartScreen extends StatelessWidget {
  const EmptyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "My Cart",
                          style: GoogleFonts.poppins(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.favorite_border_rounded, color: const Color(0xFF111827), size: 26.sp),
                            SizedBox(width: 16.w),
                            Stack(
                              children: [
                                Icon(Icons.shopping_bag_outlined, color: const Color(0xFF111827), size: 26.sp),
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    padding: EdgeInsets.all(4.r),
                                    decoration: const BoxDecoration(color: Color(0xFF6C2BFF), shape: BoxShape.circle),
                                    child: Text("0", style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 40.h),
                    const EmptyCartIllustration(),
                    SizedBox(height: 30.h),
                    
                    Text(
                      "Your cart is empty",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Looks like you haven’t added anything to your cart yet.\nExplore our collection and find something you'll love!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Action Buttons
                    Container(
                      width: double.infinity,
                      height: 60.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C2BFF), Color(0xFF8B5CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C2BFF).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22.sp),
                          SizedBox(width: 12.w),
                          Text(
                            "Start Shopping",
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      height: 60.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF6C2BFF), width: 1.5),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_outline_rounded, color: const Color(0xFF6C2BFF), size: 22.sp),
                          SizedBox(width: 12.w),
                          Text(
                            "View Wishlist",
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6C2BFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Popular Picks Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F2FF),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Popular Picks for You",
                                style: GoogleFonts.poppins(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "See All",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF6C2BFF),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: const Color(0xFF6C2BFF), size: 18.sp),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: const [
                                MiniProductCard(
                                  name: "Fastrack Men Black Analog Watch",
                                  price: "2,495",
                                  status: "In Stock",
                                  statusColor: Color(0xFF16A34A),
                                ),
                                MiniProductCard(
                                  name: "Puma Smashic Unisex Sneakers",
                                  price: "2,999",
                                  status: "In Stock",
                                  statusColor: Color(0xFF16A34A),
                                ),
                                MiniProductCard(
                                  name: "Lavie Women Green Satchel Bag",
                                  price: "1,799",
                                  status: "In Stock",
                                  statusColor: Color(0xFF16A34A),
                                ),
                                MiniProductCard(
                                  name: "boAt Rockerz 450 Headphones",
                                  price: "1,499",
                                  status: "Only 2 left",
                                  statusColor: Color(0xFFF97316),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    const SecurityShoppingCard(),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: -1),
    );
  }
}
