import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/profile/widgets/help_support_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
              color: Colors.white,
              border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
              "Help & Support",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "We're here to assist you!",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w, top: 12.h, bottom: 12.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondaryPurple),
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Icon(Icons.confirmation_number_outlined, color: AppColors.secondaryPurple, size: 18.sp),
                  SizedBox(width: 4.w),
                  Text(
                    "My Tickets",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            const SupportSearchBar(),
            SizedBox(height: 24.h),
            const QuickHelpBanner(),
            
            SizedBox(height: 32.h),
            Text(
              "How can we help you?",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 16.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.75,
              children: const [
                HelpCategoryCard(
                  icon: Icons.inventory_2_outlined,
                  title: "Orders & Delivery",
                  subtitle: "Track, cancel or change orders",
                  iconColor: Colors.purple,
                ),
                HelpCategoryCard(
                  icon: Icons.replay_rounded,
                  title: "Returns & Refunds",
                  subtitle: "Return items or check refund",
                  iconColor: Colors.orange,
                ),
                HelpCategoryCard(
                  icon: Icons.currency_rupee_rounded,
                  title: "Payments",
                  subtitle: "Payment issues, refunds & more",
                  iconColor: Colors.green,
                ),
                HelpCategoryCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Wallet & Coins",
                  subtitle: "Balance, coins & transactions",
                  iconColor: Colors.blue,
                ),
                HelpCategoryCard(
                  icon: Icons.local_offer_outlined,
                  title: "Offers & Coupons",
                  subtitle: "Find and use best offers",
                  iconColor: Colors.red,
                ),
                HelpCategoryCard(
                  icon: Icons.person_outline_rounded,
                  title: "Account & Profile",
                  subtitle: "Update your profile or details",
                  iconColor: Colors.indigo,
                ),
                HelpCategoryCard(
                  icon: Icons.security_rounded,
                  title: "Security & Privacy",
                  subtitle: "Account security and privacy help",
                  iconColor: Colors.teal,
                ),
                HelpCategoryCard(
                  icon: Icons.more_horiz_rounded,
                  title: "Other Issues",
                  subtitle: "Anything else? We're here to help",
                  iconColor: Colors.grey,
                ),
              ],
            ),

            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Popular Help Topics",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "View All",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: const [
                  PopularTopicItem(title: "How do I track my order?"),
                  Divider(height: 1),
                  PopularTopicItem(title: "How do I return or replace an item?"),
                  Divider(height: 1),
                  PopularTopicItem(title: "When will I get my refund?"),
                  Divider(height: 1),
                  PopularTopicItem(title: "How do I use a coupon code?"),
                  Divider(height: 1),
                  PopularTopicItem(title: "How to cancel my order?"),
                ],
              ),
            ),

            SizedBox(height: 32.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5FF),
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Column(
                children: [
                  Text(
                    "Still need help?",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    "Reach out to us through any of these channels.",
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: ContactChannelCard(
                          icon: Icons.call_outlined,
                          label: "Call Us",
                          value: "1800-123-4567",
                          time: "9 AM – 9 PM",
                          color: Colors.purple,
                        ),
                      ),
                      Expanded(
                        child: ContactChannelCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: "WhatsApp",
                          value: "+91 98765 43210",
                          time: "9 AM – 9 PM",
                          color: Colors.green,
                        ),
                      ),
                      Expanded(
                        child: ContactChannelCard(
                          icon: Icons.mail_outline_rounded,
                          label: "Email Us",
                          value: "support@chillfi.com",
                          time: "Response in 24h",
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: ContactChannelCard(
                          icon: Icons.public_rounded,
                          label: "Connect",
                          value: "FB & Instagram",
                          time: "We're active",
                          color: Colors.pink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
            const SafeSecureBanner(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 4),
    );
  }
}
