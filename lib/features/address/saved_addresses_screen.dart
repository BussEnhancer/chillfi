import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/address/widgets/saved_address_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  int _defaultIndex = 0;

  final List<Map<String, dynamic>> _addresses = [
    {
      'label': 'Home',
      'address': '226010, 14/285, Vivek Khand',
      'landmark': 'Near City Mall, Gomti Nagar, Lucknow, Uttar Pradesh, India\nLandmark: Opposite Toyota Showroom',
      'contactName': 'Rahul Sharma',
      'phoneNumber': '+91 98765 43210',
      'categoryColor': Colors.green,
      'badgeIcon': Icons.home_rounded,
      'categoryIcon': Icons.home_rounded,
    },
    {
      'label': 'Work',
      'address': '90, Sector 62, Noida',
      'landmark': 'Tower B, Office No. 501, Noida, Uttar Pradesh, India\nLandmark: Near HCL Campus',
      'contactName': 'Rahul Sharma',
      'phoneNumber': '+91 98765 43210',
      'categoryColor': Colors.blue,
      'badgeIcon': Icons.business_center_rounded,
      'categoryIcon': Icons.business_rounded,
    },
    {
      'label': 'Parents Home',
      'address': '7, Park Road',
      'landmark': 'Hazratganj, Lucknow, Uttar Pradesh, India\nLandmark: Near Central Bank',
      'contactName': 'Suresh Sharma (Father)',
      'phoneNumber': '+91 94567 89012',
      'categoryColor': Colors.orange,
      'badgeIcon': Icons.favorite_rounded,
      'categoryIcon': Icons.home_rounded,
    },
    {
      'label': 'Other',
      'address': '45, MG Road',
      'landmark': 'Near Metro Station, Lucknow, Uttar Pradesh, India\nLandmark: Above ICICI Bank',
      'contactName': 'Rahul Sharma',
      'phoneNumber': '+91 98765 43210',
      'categoryColor': Colors.purple,
      'badgeIcon': Icons.star_rounded,
      'categoryIcon': Icons.location_on_rounded,
    },
  ];

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
              "Saved Addresses",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "Manage your saved delivery addresses",
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
                  Icon(Icons.add_rounded, color: AppColors.secondaryPurple, size: 18.sp),
                  SizedBox(width: 4.w),
                  Text(
                    "Add New",
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
          children: [
            SizedBox(height: 20.h),
            const AddressInfoBanner(),
            SizedBox(height: 24.h),
            ...List.generate(_addresses.length, (index) {
              final address = _addresses[index];
              return SavedAddressCard(
                label: address['label'],
                address: address['address'],
                landmark: address['landmark'],
                contactName: address['contactName'],
                phoneNumber: address['phoneNumber'],
                categoryColor: address['categoryColor'],
                badgeIcon: address['badgeIcon'],
                categoryIcon: address['categoryIcon'],
                isDefault: _defaultIndex == index,
                onEdit: () {},
                onDelete: () {},
                onSetDefault: () => setState(() => _defaultIndex = index),
              );
            }),
            const SecurityBannerCard(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
