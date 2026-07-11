import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportSearchBar extends StatelessWidget {
  const SupportSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.greyText, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for help topics, orders or issues...",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: AppColors.greyText,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickHelpBanner extends StatelessWidget {
  const QuickHelpBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.headset_mic_outlined, color: AppColors.secondaryPurple, size: 30.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Need quick help?",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Our support team is ready to assist you. Get in touch and we'll respond shortly.",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText, height: 1.4),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            children: [
              GestureDetector(
                onTap: () => launchUrl(Uri.parse('https://wa.me/919056224993'), mode: LaunchMode.externalApplication),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        "Chat with Us",
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, color: AppColors.greyText, size: 12.sp),
                  SizedBox(width: 4.w),
                  Text(
                    "9 AM – 9 PM, Every day",
                    style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.greyText, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HelpCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback? onTap;

  const HelpCategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
              height: 1.1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 8.5.sp,
              color: AppColors.greyText,
              height: 1.1,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class PopularTopicItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const PopularTopicItem({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.description_outlined, color: AppColors.secondaryPurple, size: 18.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 22.sp),
        ],
      ),
      ),
    );
  }
}

class ContactChannelCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String time;
  final Color color;
  final VoidCallback? onTap;

  const ContactChannelCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.time,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 8.sp, color: AppColors.greyText, fontWeight: FontWeight.w600),
        ),
        Text(
          time,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 7.sp, color: AppColors.greyText),
        ),
      ],
      ),
    );
  }
}

class SafeSecureBanner extends StatelessWidget {
  final VoidCallback? onTap;
  const SafeSecureBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E7),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: Colors.amber[800], size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Safe & Secure",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber[900],
                  ),
                ),
                Text(
                  "Your information is safe with us. We respect your privacy.",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.amber[800]),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.amber[800], size: 24.sp),
        ],
      ),
      ),
    );
  }
}
