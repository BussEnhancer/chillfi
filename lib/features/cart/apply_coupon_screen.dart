import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/cart/widgets/coupon_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ApplyCouponScreen extends StatefulWidget {
  const ApplyCouponScreen({super.key});

  @override
  State<ApplyCouponScreen> createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends State<ApplyCouponScreen> {
  int _selectedCouponIndex = -1;

  final List<Map<String, dynamic>> _coupons = [
    {
      'code': 'FLAT15',
      'title': 'Flat 15% OFF',
      'desc': 'Get flat 15% off on all orders above ₹4,999',
      'validity': 'Valid till 31 May 2025',
      'color': AppColors.secondaryPurple,
    },
    {
      'code': 'CART10',
      'title': 'Flat ₹1,000 OFF',
      'desc': 'Get flat ₹1,000 off on all orders above ₹7,999',
      'validity': 'Valid till 25 May 2025',
      'color': AppColors.primaryOrange,
    },
    {
      'code': 'NEW20',
      'title': '20% OFF up to ₹2,000',
      'desc': 'Get 20% off up to ₹2,000 on your first order',
      'validity': 'Valid till 20 May 2025',
      'color': Colors.green,
    },
    {
      'code': 'BANK5',
      'title': 'Extra 5% OFF',
      'desc': 'Get extra 5% off on prepaid orders',
      'validity': 'Valid till 31 May 2025',
      'color': AppColors.primaryOrange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.r),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 22.sp),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Apply Coupon or Offers",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "Save extra on your order",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(
                "How it works?",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryPurple,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.help_outline_rounded, color: AppColors.secondaryPurple, size: 18.sp),
              SizedBox(width: 16.w),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                // Coupon Entry Card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.lightGrey.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryPurple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.local_offer_outlined, color: AppColors.secondaryPurple, size: 18.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Have a Coupon Code?",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                Text(
                                  "Enter it and get amazing discounts",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Enter coupon code",
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    color: AppColors.greyText.withOpacity(0.5),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "Apply",
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryPurple,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24.h),
                Text(
                  "Available Coupons",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Coupon List
                ...List.generate(_coupons.length, (index) {
                  final coupon = _coupons[index];
                  return CouponCardWidget(
                    code: coupon['code'],
                    title: coupon['title'],
                    desc: coupon['desc'],
                    validity: coupon['validity'],
                    themeColor: coupon['color'],
                    isSelected: _selectedCouponIndex == index,
                    onTap: () => setState(() => _selectedCouponIndex = index),
                  );
                }),
                
                // Best Coupon Card
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: Colors.green, size: 20.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Best Coupon Applied Automatically",
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.green[800],
                              ),
                            ),
                            Text(
                              "We'll apply the best available coupon at checkout",
                              style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.stars_rounded, color: Colors.green, size: 10.sp),
                            SizedBox(width: 4.w),
                            Text(
                              "BEST PRICE",
                              style: GoogleFonts.poppins(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 160.h), // Footer space
              ],
            ),
          ),
          
          // Sticky Bottom Section
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomActionSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionSection() {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 30.h),
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
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryRow("Price (3 Items)", "₹1,38,997"),
                      SizedBox(height: 8.h),
                      _buildSummaryRow("Total Savings", "-₹32,000", isSavings: true),
                      SizedBox(height: 12.h),
                      Divider(color: AppColors.lightGrey.withOpacity(0.5)),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                          Text(
                            "₹1,06,997",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "You will save ₹32,000 on this order",
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.w),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 56.h,
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
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
                    child: Text(
                      "Continue",
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 14.sp, color: AppColors.greyText),
                SizedBox(width: 6.w),
                Text(
                  "Safe & Secure Payments",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isSavings = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: AppColors.greyText,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isSavings ? Colors.green : AppColors.darkText,
          ),
        ),
      ],
    );
  }
}
