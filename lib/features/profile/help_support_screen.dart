import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/orders/my_orders_screen.dart';
import 'package:chillfi/features/profile/privacy_policy_screen.dart';
import 'package:chillfi/features/profile/widgets/help_support_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support tickets are coming soon. Please use Call/WhatsApp/Email for now.')),
              ),
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
              crossAxisCount: 3,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.85,
              children: [
                HelpCategoryCard(
                  icon: Icons.inventory_2_outlined,
                  title: "Orders & Delivery",
                  subtitle: "Track, cancel or change orders",
                  iconColor: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                ),
                HelpCategoryCard(
                  icon: Icons.replay_rounded,
                  title: "Returns & Refunds",
                  subtitle: "Return items or check refund",
                  iconColor: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                ),
                HelpCategoryCard(
                  icon: Icons.currency_rupee_rounded,
                  title: "Payments",
                  subtitle: "Payment issues, refunds & more",
                  iconColor: Colors.green,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                ),
                HelpCategoryCard(
                  icon: Icons.person_outline_rounded,
                  title: "Account & Profile",
                  subtitle: "Update your profile or details",
                  iconColor: Colors.indigo,
                  onTap: () => Navigator.pop(context),
                ),
                HelpCategoryCard(
                  icon: Icons.security_rounded,
                  title: "Security & Privacy",
                  subtitle: "Account security and privacy help",
                  iconColor: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                ),
                HelpCategoryCard(
                  icon: Icons.more_horiz_rounded,
                  title: "Other Issues",
                  subtitle: "Anything else? We're here to help",
                  iconColor: Colors.grey,
                  onTap: () => launchUrl(Uri.parse('https://wa.me/919056224993'), mode: LaunchMode.externalApplication),
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
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('More help topics are coming soon.')),
                  ),
                  child: Text(
                    "View All",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryPurple,
                    ),
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
                children: [
                  PopularTopicItem(
                    title: "How do I track my order?",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                  ),
                  const Divider(height: 1),
                  PopularTopicItem(
                    title: "How do I return or replace an item?",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                  ),
                  const Divider(height: 1),
                  PopularTopicItem(
                    title: "When will I get my refund?",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                  ),
                  const Divider(height: 1),
                  PopularTopicItem(
                    title: "How to cancel my order?",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                  ),
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
                    children: [
                      Expanded(
                        child: ContactChannelCard(
                          icon: Icons.call_outlined,
                          label: "Call Us",
                          value: "+91 90562 24993",
                          time: "9 AM – 9 PM",
                          color: Colors.purple,
                          onTap: () => launchUrl(Uri.parse('tel:919056224993')),
                        ),
                      ),
                      Expanded(
                        child: ContactChannelCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: "WhatsApp",
                          value: "+91 90562 24993",
                          time: "9 AM – 9 PM",
                          color: Colors.green,
                          onTap: () => launchUrl(Uri.parse('https://wa.me/919056224993'), mode: LaunchMode.externalApplication),
                        ),
                      ),
                      Expanded(
                        child: ContactChannelCard(
                          icon: Icons.mail_outline_rounded,
                          label: "Email Us",
                          value: "support@chillfi.com",
                          time: "Response in 24h",
                          color: Colors.blue,
                          onTap: () => launchUrl(Uri.parse('mailto:support@chillfi.com')),
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
            SafeSecureBanner(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 4),
    );
  }
}
