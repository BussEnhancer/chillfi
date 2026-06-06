import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/address/widgets/address_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryAddressCard extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final String type;
  final IconData typeIcon;
  final Color typeColor;
  final bool isSelected;
  final bool isDefault;
  final bool fastDelivery;
  final List<Map<String, dynamic>> extraTags;
  final VoidCallback onTap;

  const DeliveryAddressCard({
    super.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.type,
    required this.typeIcon,
    required this.typeColor,
    required this.isSelected,
    this.isDefault = false,
    this.fastDelivery = false,
    this.extraTags = const [],
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radio Button
                Container(
                  width: 20.r,
                  height: 20.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey,
                      width: isSelected ? 6.r : 1.5,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Icon Card
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                          if (isDefault) ...[
                            SizedBox(width: 8.w),
                            const AddressTypeBadge(label: "Default", color: Colors.purple),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          AddressTypeBadge(label: type, color: typeColor),
                          SizedBox(width: 8.w),
                          Text(
                            "•  +91 $phone",
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                _buildActionButtons(),
              ],
            ),
            
            Padding(
              padding: EdgeInsets.only(left: 32.w + 30.r, top: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      if (isDefault) 
                        const AddressTagChip(icon: Icons.verified_rounded, label: "Default Address", color: Colors.green),
                      if (fastDelivery)
                        const AddressTagChip(icon: Icons.bolt_rounded, label: "Fast Delivery", color: Colors.green),
                      ...extraTags.map((tag) => AddressTagChip(
                        icon: tag['icon'] as IconData,
                        label: tag['label'] as String,
                        color: tag['color'] as Color,
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionItem(Icons.edit_outlined, "Edit"),
        SizedBox(width: 12.w),
        _buildActionItem(Icons.delete_outline_rounded, "Remove"),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.greyText),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }
}
