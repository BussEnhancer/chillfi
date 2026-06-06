import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/profile/widgets/edit_profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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
              "Edit Profile",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "Update your personal information",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "Save",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryPurple,
              ),
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            const ProfilePhotoEditCard(),
            
            const EditProfileSectionTitle(title: "Personal Information"),
            Row(
              children: [
                const Expanded(
                  child: PremiumEditField(
                    label: "Full Name",
                    value: "Rahul Sharma",
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                ),
                SizedBox(width: 16.w),
                const Expanded(
                  child: PremiumEditField(
                    label: "Phone Number",
                    value: "+91 98765 43210",
                    prefixIcon: Icons.phone_outlined,
                  ),
                ),
              ],
            ),
            const PremiumEditField(
              label: "Email Address",
              value: "rahul.sharma@example.com",
              prefixIcon: Icons.mail_outline_rounded,
            ),
            Row(
              children: [
                const Expanded(
                  child: PremiumDropdownField(
                    label: "Date of Birth",
                    value: "15 Aug 1995",
                    prefixIcon: Icons.calendar_today_outlined,
                  ),
                ),
                SizedBox(width: 16.w),
                const Expanded(
                  child: PremiumDropdownField(
                    label: "Gender",
                    value: "Male",
                    prefixIcon: Icons.person_2_outlined,
                  ),
                ),
              ],
            ),

            const EditProfileSectionTitle(title: "Address"),
            const PremiumEditField(
              label: "Address Line 1",
              value: "226010, 14/285, Vivek Khand",
              prefixIcon: Icons.location_on_outlined,
            ),
            const PremiumEditField(
              label: "Address Line 2",
              value: "Near City Mall, Gomti Nagar",
              prefixIcon: Icons.business_outlined,
              isOptional: true,
            ),
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: PremiumEditField(
                    label: "City",
                    value: "Lucknow",
                    prefixIcon: Icons.location_city_outlined,
                  ),
                ),
                SizedBox(width: 12.w),
                const Expanded(
                  flex: 3,
                  child: PremiumDropdownField(
                    label: "State",
                    value: "Uttar Pradesh",
                    prefixIcon: Icons.map_outlined,
                  ),
                ),
                SizedBox(width: 12.w),
                const Expanded(
                  flex: 2,
                  child: PremiumEditField(
                    label: "Pincode",
                    value: "226010",
                    prefixIcon: Icons.pin_drop_outlined,
                  ),
                ),
              ],
            ),
            const PremiumDropdownField(
              label: "Country",
              value: "India",
              prefixIcon: Icons.public_rounded,
            ),

            const EditProfileSectionTitle(title: "Preferences"),
            const PremiumDropdownField(
              label: "Preferred Language",
              value: "English",
              prefixIcon: Icons.language_rounded,
            ),
            const PremiumDropdownField(
              label: "Preferred Currency",
              value: "INR (₹)",
              prefixIcon: Icons.currency_rupee_rounded,
            ),

            SizedBox(height: 32.h),
            Container(
              width: double.infinity,
              height: 60.h,
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryPurple.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, color: Colors.white, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(
                    "Save Changes",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20.sp),
                  SizedBox(width: 10.w),
                  Text(
                    "Delete Account",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
