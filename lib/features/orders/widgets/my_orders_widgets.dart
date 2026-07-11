import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSearchBar extends StatelessWidget {
  const OrderSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.greyText, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search orders, products, brands...",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: AppColors.greyText,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Icon(Icons.mic_none_rounded, color: AppColors.greyText, size: 22.sp),
        ],
      ),
    );
  }
}

class OrderFilterTabs extends StatefulWidget {
  const OrderFilterTabs({super.key});

  @override
  State<OrderFilterTabs> createState() => _OrderFilterTabsState();
}

class _OrderFilterTabsState extends State<OrderFilterTabs> {
  int selectedIndex = 0;
  final List<String> tabs = [
    "All Orders",
    "Processing",
    "Shipped",
    "Delivered",
    "Cancelled",
    "Returned"
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.purpleGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: isSelected ? null : Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
              ),
              child: Text(
                tabs[index],
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.greyText,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class LatestOrderBanner extends StatelessWidget {
  const LatestOrderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFFF),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.inventory_2_rounded, color: AppColors.secondaryPurple, size: 30.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your latest order is on the way 🚚",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Order ID: #CHILLFI125678",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                ),
                RichText(
                  text: TextSpan(
                    text: "Expected Delivery: ",
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                    children: [
                      TextSpan(
                        text: "24 May 2026",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Text(
                  "Track Order",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
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
}

class OngoingOrderCard extends StatelessWidget {
  const OngoingOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order ID", style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText)),
                  Text("#CHILLFI125678", style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order Date", style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText)),
                  Text("21 May 2026", style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  "Processing",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 32.h, color: AppColors.lightGrey.withValues(alpha: 0.3)),
          Row(
            children: [
              Container(
                width: 70.r,
                height: 70.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.smartphone_rounded, color: Colors.grey[300], size: 40.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Apple iPhone 15 (128GB)",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "Pink • 128GB  |  Qty: 1",
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                    ),
                    Text(
                      "₹69,999",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          const OrderTrackingTimeline(),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, color: AppColors.secondaryPurple, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "Expected Delivery: 24 May 2026",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "Track Order >",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderTrackingTimeline extends StatelessWidget {
  const OrderTrackingTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep("Confirmed", "21 May", true, true),
        _buildLine(true),
        _buildStep("Packed", "22 May", true, true),
        _buildLine(true),
        _buildStep("Shipped", "23 May", true, false),
        _buildLine(false),
        _buildStep("Delivered", "", false, false),
      ],
    );
  }

  Widget _buildStep(String label, String date, bool isCompleted, bool isCurrent) {
    return Column(
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.secondaryPurple : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? AppColors.secondaryPurple : AppColors.lightGrey,
              width: 1.5,
            ),
          ),
          child: isCompleted ? Icon(Icons.check, color: Colors.white, size: 14.sp) : null,
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
            color: isCompleted ? AppColors.darkText : AppColors.greyText,
          ),
        ),
        if (date.isNotEmpty)
          Text(
            date,
            style: GoogleFonts.poppins(fontSize: 8.sp, color: AppColors.greyText),
          ),
      ],
    );
  }

  Widget _buildLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: EdgeInsets.only(bottom: 30.h),
        color: isCompleted ? AppColors.secondaryPurple : AppColors.lightGrey.withValues(alpha: 0.5),
      ),
    );
  }
}

class DeliveredOrderCard extends StatelessWidget {
  const DeliveredOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60.r,
                height: 60.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.headset_rounded, color: Colors.grey[300], size: 30.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Apple AirPods Pro (2nd Gen)",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "Order ID: #CHILLFI124567",
                      style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
                    ),
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.green, size: 14.sp),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            "Delivered on 12 May 2026",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  "Delivered",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(Icons.refresh_rounded, "Buy Again"),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionBtn(Icons.star_outline_rounded, "Write Review"),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionBtn(null, "View Details"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData? icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.secondaryPurple, size: 16.sp),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            if (icon == null) ...[
              SizedBox(width: 4.w),
              Icon(Icons.chevron_right_rounded, color: AppColors.greyText, size: 16.sp),
            ],
          ],
        ),
      ),
    );
  }
}

class CancelledOrderCard extends StatelessWidget {
  const CancelledOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60.r,
                height: 60.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.smartphone_rounded, color: Colors.grey[300], size: 30.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Samsung Galaxy S23 (256GB)",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "Order ID: #CHILLFI124123",
                      style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
                    ),
                    Text(
                      "Cancelled on 06 May 2026",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  "Cancelled",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Reason: Payment Failed",
                style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Text(
                      "View Details",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.greyText, size: 16.sp),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderStatsSection extends StatelessWidget {
  const OrderStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.shopping_bag_outlined, "24", "Total Orders", Colors.purple)),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatCard(Icons.check_circle_outline_rounded, "18", "Delivered", Colors.green)),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatCard(Icons.local_shipping_outlined, "3", "Processing", Colors.orange)),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatCard(Icons.cancel_outlined, "3", "Cancelled", Colors.red)),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 8.sp, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      children: [
        _buildActionCard(Icons.local_shipping_outlined, "Track Order", "Track your orders"),
        _buildActionCard(Icons.favorite_border_rounded, "My Wishlist", "View saved items"),
        _buildActionCard(Icons.description_outlined, "Invoices", "Download bills"),
        _buildActionCard(Icons.headset_mic_outlined, "Support", "Help & Support"),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.secondaryPurple, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderRecommendations extends StatelessWidget {
  const OrderRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildRecCard("Apple AirPods 4", "12,999"),
          _buildRecCard("Samsung Galaxy Watch 6", "24,999"),
          _buildRecCard("iPad Air M2", "54,900"),
          _buildRecCard("OnePlus 12R", "39,999"),
        ],
      ),
    );
  }

  Widget _buildRecCard(String title, String price) {
    return Container(
      width: 150.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: Colors.grey[300], size: 40.sp),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "₹$price",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.secondaryPurple),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_shopping_cart_rounded, color: AppColors.secondaryPurple, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        "Add to Cart",
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StickyTrackCTA extends StatelessWidget {
  const StickyTrackCTA({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPurple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_rounded, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Track Latest Order",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Stay updated with your order status",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18.sp),
        ],
      ),
    );
  }
}
