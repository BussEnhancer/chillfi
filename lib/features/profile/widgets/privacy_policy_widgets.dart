import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyHeroBanner extends StatelessWidget {
  const PrivacyHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.shield_rounded, color: AppColors.secondaryPurple.withValues(alpha: 0.1), size: 80.sp),
                Icon(Icons.lock_person_rounded, color: AppColors.secondaryPurple, size: 40.sp),
              ],
            ),
          ),
          Container(width: 1, height: 70.h, color: AppColors.lightGrey.withValues(alpha: 0.5)),
          SizedBox(width: 20.w),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your privacy is our priority",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "At CHILLFI, we are committed to protecting your personal information and being transparent.",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                    height: 1.4,
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

class PolicyIndexCard extends StatelessWidget {
  const PolicyIndexCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.info_outline_rounded, 'title': '1. Information We Collect'},
      {'icon': Icons.settings_suggest_outlined, 'title': '2. How We Use Your Information'},
      {'icon': Icons.share_outlined, 'title': '3. Information Sharing & Disclosure'},
      {'icon': Icons.lock_outline_rounded, 'title': '4. Data Security'},
      {'icon': Icons.person_outline_rounded, 'title': '5. Your Rights & Choices'},
      {'icon': Icons.track_changes_rounded, 'title': '6. Cookies & Tracking Technologies'},
      {'icon': Icons.child_care_rounded, 'title': '7. Children\'s Privacy'},
      {'icon': Icons.edit_note_rounded, 'title': '8. Changes to This Privacy Policy'},
      {'icon': Icons.mail_outline_rounded, 'title': '9. Contact Us'},
    ];

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9E9EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "In this policy",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 16.h),
          ...items.map((item) => _buildIndexItem(item['icon'], item['title'])),
        ],
      ),
    );
  }

  Widget _buildIndexItem(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondaryPurple, size: 18.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 20.sp),
        ],
      ),
    );
  }
}

class ExpandablePolicyCard extends StatefulWidget {
  const ExpandablePolicyCard({super.key});

  @override
  State<ExpandablePolicyCard> createState() => _ExpandablePolicyCardState();
}

class _ExpandablePolicyCardState extends State<ExpandablePolicyCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE9E9EF)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.secondaryPurple, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    "1. Information We Collect",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.greyText,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            SizedBox(height: 16.h),
            Text(
              "We collect information that you provide to us directly and indirectly when you use CHILLFI. This includes:",
              style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText, height: 1.5),
            ),
            SizedBox(height: 12.h),
            _buildBulletPoint("Personal Information:", "Name, email address, phone number, address and other contact details."),
            _buildBulletPoint("Account Information:", "Login credentials, profile details and preferences."),
            _buildBulletPoint("Order & Transaction Information:", "Order history, payment details, billing and delivery information."),
            _buildBulletPoint("Device & Usage Information:", "IP address, device type, browser type, pages viewed and app usage data."),
            SizedBox(height: 12.h),
            Text(
              "We collect this information to provide and improve our services to you.",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
                color: AppColors.greyText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String title, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Container(
              width: 5.r,
              height: 5.r,
              decoration: const BoxDecoration(
                color: AppColors.secondaryPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: AppColors.greyText,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: " $desc"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyCommitmentBanner extends StatelessWidget {
  const PrivacyCommitmentBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.lock_outline_rounded, color: AppColors.secondaryPurple, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "We do not sell your personal information.",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Your data is used only to serve you better.",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_user_outlined, color: AppColors.secondaryPurple.withValues(alpha: 0.3), size: 40.sp),
        ],
      ),
    );
  }
}
