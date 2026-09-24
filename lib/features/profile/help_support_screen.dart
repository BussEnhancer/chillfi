import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:chillfi/features/profile/edit_profile_screen.dart';
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

  void _showAnswer(BuildContext context, String q, String a) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
            SizedBox(height: 10.h),
            Text(a, style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText, height: 1.5)),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text('Go to My Orders', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
    if (!ok && context.mounted) {
      AppErrorDialog.show(context, title: "Couldn't open that app", message: 'Please call or email us at support@chillfi.com.');
    }
  }

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
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "We're here to help!",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
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
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
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
                    onTap: () => _showAnswer(context, "How do I track my order?", "Open Account → My Orders, tap your order and choose Track Order. Once your parcel is handed to Delhivery you'll see live scans there, and we also send you notifications at every step."),
                  ),
                  const Divider(height: 1),
                  PopularTopicItem(
                    title: "How do I return or replace an item?",
                    onTap: () => _showAnswer(context, "How do I return or replace an item?", "Most products can be returned within 7 days of delivery. Open the delivered order in My Orders and tap Request Refund / Return, choose the type and tell us the reason. Our team will review it and update the status on the same screen."),
                  ),
                  const Divider(height: 1),
                  PopularTopicItem(
                    title: "When will I get my refund?",
                    onTap: () => _showAnswer(context, "When will I get my refund?", "For online payments, refunds are processed after your cancellation or return is approved and usually reach you in 5–7 business days, depending on your bank. You can see the refund status on the order's details screen."),
                  ),
                  const Divider(height: 1),
                  PopularTopicItem(
                    title: "How to cancel my order?",
                    onTap: () => _showAnswer(context, "How to cancel my order?", "Open the order in My Orders and tap Cancel Order. Orders can be cancelled until the courier picks them up. If you paid online, a refund is started automatically."),
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
                          onTap: () => _open(context, Uri.parse('tel:+919056224993')),
                        ),
                      ),
                      Expanded(
                        child: ContactChannelCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: "WhatsApp",
                          value: "+91 90562 24993",
                          time: "9 AM – 9 PM",
                          color: Colors.green,
                          onTap: () => _open(context, Uri.parse('https://wa.me/919056224993')),
                        ),
                      ),
                      Expanded(
                        child: ContactChannelCard(
                          icon: Icons.mail_outline_rounded,
                          label: "Email Us",
                          value: "support@chillfi.com",
                          time: "Response in 24h",
                          color: Colors.blue,
                          onTap: () => _open(context, Uri.parse('mailto:support@chillfi.com')),
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
