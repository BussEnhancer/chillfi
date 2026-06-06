import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressInfoBanner extends StatelessWidget {
  const AddressInfoBanner({super.key});

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
            padding: EdgeInsets.all(10.r),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on_rounded, color: AppColors.secondaryPurple, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select an address during checkout",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "You can add up to 10 addresses",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.map_outlined, color: AppColors.secondaryPurple.withValues(alpha: 0.3), size: 40.sp),
        ],
      ),
    );
  }
}

class SavedAddressCard extends StatelessWidget {
  final String label;
  final String address;
  final String landmark;
  final String contactName;
  final String phoneNumber;
  final Color categoryColor;
  final IconData badgeIcon;
  final IconData categoryIcon;
  final bool isDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const SavedAddressCard({
    super.key,
    required this.label,
    required this.address,
    required this.landmark,
    required this.contactName,
    required this.phoneNumber,
    required this.categoryColor,
    required this.badgeIcon,
    required this.categoryIcon,
    this.isDefault = false,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(badgeIcon, size: 12.sp, color: categoryColor),
                          SizedBox(width: 4.w),
                          Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (isDefault)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              "Default",
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        SizedBox(width: 12.w),
                        Icon(Icons.more_vert, color: AppColors.greyText, size: 20.sp),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 45.r,
                      height: 45.r,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(categoryIcon, color: categoryColor, size: 22.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                          Text(
                            landmark,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: AppColors.greyText,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Text(
                                contactName,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryPurple.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  phoneNumber,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondaryPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.lightGrey.withValues(alpha: 0.3)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onSetDefault,
                  child: Row(
                    children: [
                      Container(
                        width: 18.r,
                        height: 18.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDefault ? AppColors.secondaryPurple : Colors.white,
                          border: Border.all(
                            color: isDefault ? AppColors.secondaryPurple : AppColors.lightGrey,
                            width: isDefault ? 5.r : 1.5,
                          ),
                        ),
                        child: isDefault ? Icon(Icons.check, color: Colors.white, size: 10.sp) : null,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        isDefault ? "Default Address" : "Set as Default",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: isDefault ? AppColors.secondaryPurple : AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildActionButton(Icons.edit_outlined, "Edit", AppColors.secondaryPurple, onEdit),
                    SizedBox(width: 20.w),
                    _buildActionButton(Icons.delete_outline_rounded, "Delete", Colors.red, onDelete),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class SecurityBannerCard extends StatelessWidget {
  const SecurityBannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user_outlined, color: AppColors.secondaryPurple, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your addresses are secure",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "We never share your address with anyone.",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.greyText, size: 24.sp),
        ],
      ),
    );
  }
}
