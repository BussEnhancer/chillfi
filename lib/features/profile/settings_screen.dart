import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/profile/edit_profile_screen.dart';
import 'package:chillfi/features/profile/notification_settings_screen.dart';
import 'package:chillfi/features/profile/privacy_policy_screen.dart';
import 'package:chillfi/features/profile/help_support_screen.dart';
import 'package:chillfi/features/profile/about_us_screen.dart';
import 'package:chillfi/core/widgets/app_back_button.dart';
import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/features/auth/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:chillfi/features/profile/terms_and_conditions_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60.w,
        leading: Padding(padding: EdgeInsets.only(left: 16.w), child: const AppBackButton()),
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildSettingsItem(
              context,
              Icons.person_outline_rounded,
              "Account Settings",
              "Edit your profile information",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
            ),
            _buildSettingsItem(
              context,
              Icons.notifications_none_rounded,
              "Notifications",
              "Manage your alert preferences",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
            ),
            _buildSettingsItem(
              context,
              Icons.security_rounded,
              "Privacy & Security",
              "Privacy policy and security settings",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())),
            ),
            _buildSettingsItem(
              context,
              Icons.help_outline_rounded,
              "Help & Support",
              "Get assistance and support",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen())),
            ),
            _buildSettingsItem(
              context,
              Icons.description_outlined,
              "Policies",
              "Terms, refunds, returns and shipping",
              onTap: () => _showPolicies(context),
            ),
            _buildSettingsItem(
              context,
              Icons.info_outline_rounded,
              "About CHILLFI",
              "Information about our company",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen())),
            ),
            // Account deletion inside the app (Google Play / App Store requirement for apps with sign-up)
            if (context.watch<AuthProvider>().user != null) ...[
              SizedBox(height: 8.h),
              _buildSettingsItem(
                context,
                Icons.delete_forever_rounded,
                "Delete account",
                "Permanently remove your account and personal data",
                danger: true,
                onTap: () => _confirmDelete(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Terms live in the app; refund / return / shipping policies are the website pages (one source of truth).
  void _showPolicies(BuildContext context) {
    Future<void> open(String path) async {
      final ok = await launchUrl(Uri.parse('https://chillfi.in$path'), mode: LaunchMode.externalApplication).catchError((_) => false);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't open the page. Please visit chillfi.in")));
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Text('Policies', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
            SizedBox(height: 8.h),
            ListTile(
              leading: const Icon(Icons.gavel_rounded, color: AppColors.secondaryPurple),
              title: const Text('Terms & Conditions'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()));
              },
            ),
            for (final p in const [
              ['Refund Policy', '/refund-policy', Icons.currency_rupee_rounded],
              ['Return Policy', '/return-policy', Icons.assignment_return_outlined],
              ['Shipping Policy', '/shipping-policy', Icons.local_shipping_outlined],
            ])
              ListTile(
                leading: Icon(p[2] as IconData, color: AppColors.secondaryPurple),
                title: Text(p[0] as String),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.greyText),
                onTap: () {
                  Navigator.pop(ctx);
                  open(p[1] as String);
                },
              ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final wishlist = context.read<WishlistProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'This permanently deletes your profile, wishlist, reviews, saved addresses and notifications. '
          'Past orders are kept without your name for tax records. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await auth.deleteAccount();
      cart.reset();
      wishlist.reset();
      navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const WelcomeScreen()), (r) => false);
      messenger.showSnackBar(const SnackBar(content: Text('Your account has been deleted.')));
    } catch (e) {
      if (context.mounted) AppErrorDialog.show(context, error: e, title: "Couldn't delete account");
    }
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, String subtitle, {required VoidCallback onTap, bool danger = false}) {
    final tint = danger ? Colors.red.shade400 : AppColors.secondaryPurple;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: tint, size: 22.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: danger ? Colors.red.shade400 : AppColors.darkText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
