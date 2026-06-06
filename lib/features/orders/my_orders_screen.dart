import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/orders/widgets/my_orders_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Orders",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "Track and manage your purchases",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        actions: [
          _buildActionCircle(Icons.search_rounded),
          SizedBox(width: 12.w),
          _buildActionCircle(Icons.tune_rounded),
          SizedBox(width: 20.w),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                const OrderSearchBar(),
                SizedBox(height: 24.h),
                const OrderFilterTabs(),
                SizedBox(height: 24.h),
                const LatestOrderBanner(),
                
                SizedBox(height: 32.h),
                const SectionHeader(title: "Ongoing Orders"),
                SizedBox(height: 16.h),
                const OngoingOrderCard(),

                SizedBox(height: 12.h),
                const SectionHeader(title: "Delivered Orders"),
                SizedBox(height: 16.h),
                const DeliveredOrderCard(),

                SizedBox(height: 12.h),
                const SectionHeader(title: "Cancelled Orders"),
                SizedBox(height: 16.h),
                const CancelledOrderCard(),

                SizedBox(height: 12.h),
                const OrderStatsSection(),

                SizedBox(height: 32.h),
                const SectionHeader(title: "Quick Actions"),
                SizedBox(height: 16.h),
                const QuickActionsSection(),

                SizedBox(height: 32.h),
                const SectionHeader(title: "Based on your purchases"),
                SizedBox(height: 16.h),
                const OrderRecommendations(),

                SizedBox(height: 150.h), // Space for sticky CTA and bottom nav
              ],
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: const StickyTrackCTA(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
    );
  }

  Widget _buildActionCircle(IconData icon) {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.darkText, size: 20.sp),
    );
  }
}
