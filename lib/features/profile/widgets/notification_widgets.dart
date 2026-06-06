import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationWelcomeBanner extends StatelessWidget {
  const NotificationWelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Icon(Icons.notifications_active_rounded, color: AppColors.secondaryPurple, size: 30.sp),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10.r,
                    height: 10.r,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stay updated, your way",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Choose what notifications you want to receive and how we can reach you.",
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

class NotificationSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const NotificationSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.secondaryPurple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.secondaryPurple, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text(
              "Expand",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryPurple,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryPurple, size: 18.sp),
          ],
        ),
      ],
    );
  }
}

class NotificationToggleItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const NotificationToggleItem({
    super.key,
    this.icon,
    required this.title,
    this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.secondaryPurple, size: 20.sp),
            SizedBox(width: 16.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: AppColors.greyText,
                    ),
                  ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.secondaryPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class NotificationChannelsCard extends StatelessWidget {
  const NotificationChannelsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.secondaryPurple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.mail_outline_rounded, color: AppColors.secondaryPurple, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notification Channels",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "Choose how you want to receive notifications",
                      style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChannelItem(Icons.phone_android_rounded, "Push", true),
              _buildChannelItem(Icons.mail_outline_rounded, "Email", true),
              _buildChannelItem(Icons.chat_bubble_outline_rounded, "SMS", false),
              _buildChannelItem(Icons.whatsapp_rounded, "WhatsApp", true),
              Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 24.sp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelItem(IconData icon, String label, bool isSelected) {
    return Column(
      children: [
        Icon(icon, color: isSelected ? AppColors.darkText : AppColors.lightGrey, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.darkText : AppColors.greyText,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 16.r,
          height: 16.r,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondaryPurple : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey, width: 1),
          ),
          child: isSelected ? Icon(Icons.check, color: Colors.white, size: 10.sp) : null,
        ),
      ],
    );
  }
}

class DNDCard extends StatelessWidget {
  const DNDCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.notifications_off_outlined, color: AppColors.secondaryPurple, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Do Not Disturb",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Pause all non-important notifications for a specific time",
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText, height: 1.4),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "10:00 PM - 8:00 AM",
                style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                "Everyday",
                style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.greyText),
              ),
            ],
          ),
          SizedBox(width: 8.w),
          Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 24.sp),
        ],
      ),
    );
  }
}

class NotificationPrivacyFooter extends StatelessWidget {
  const NotificationPrivacyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded, color: AppColors.greyText, size: 14.sp),
        SizedBox(width: 8.w),
        Text(
          "We respect your privacy and never spam",
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
