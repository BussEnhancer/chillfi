import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/address/add_new_address_screen.dart';
import 'package:chillfi/features/address/widgets/delivery_address_card.dart';
import 'package:chillfi/features/address/widgets/delivery_bottom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _addresses = [
    {
      'name': 'John Sharma',
      'phone': '98765 43210',
      'type': 'HOME',
      'typeIcon': Icons.home_rounded,
      'typeColor': AppColors.secondaryPurple,
      'isDefault': true,
      'fastDelivery': true,
      'address': '226010, 14/285, Vivek Khand, Gomti Nagar, Lucknow, Uttar Pradesh, India',
      'extraTags': [],
    },
    {
      'name': 'Rahul Sharma',
      'phone': '91234 56789',
      'type': 'WORK',
      'typeIcon': Icons.business_rounded,
      'typeColor': Colors.orange,
      'isDefault': false,
      'fastDelivery': true,
      'address': '201301, Tower A, Office No. 503, Sector 62, Noida, Uttar Pradesh, India',
      'extraTags': [
        {'icon': Icons.business_center_rounded, 'label': 'Office', 'color': Colors.purple},
      ],
    },
    {
      'name': 'Priya Sharma',
      'phone': '99887 76655',
      'type': 'OTHER',
      'typeIcon': Icons.favorite_rounded,
      'typeColor': Colors.pink,
      'isDefault': false,
      'fastDelivery': true,
      'address': '110001, D-45, Lajpat Nagar 2, New Delhi, Delhi, India',
      'extraTags': [
        {'icon': Icons.family_restroom_rounded, 'label': 'Family', 'color': Colors.pink},
      ],
    },
    {
      'name': 'Amit Sharma',
      'phone': '88776 65544',
      'type': 'OTHER',
      'typeIcon': Icons.location_on_rounded,
      'typeColor': Colors.blue,
      'isDefault': false,
      'fastDelivery': true,
      'address': '560001, 12th Cross, Indiranagar, Bangalore, Karnataka, India',
      'extraTags': [
        {'icon': Icons.people_rounded, 'label': 'Parents', 'color': Colors.blue},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.r),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 22.sp),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivery Address",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "Select a delivery address",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddNewAddressScreen()),
              );
            },
            child: Row(
              children: [
                Icon(Icons.add_circle_outline_rounded, color: AppColors.secondaryPurple, size: 20.sp),
                SizedBox(width: 4.w),
                Text(
                  "Add New",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryPurple,
                  ),
                ),
                SizedBox(width: 16.w),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            physics: const BouncingScrollPhysics(),
            itemCount: _addresses.length,
            itemBuilder: (context, index) {
              final address = _addresses[index];
              return DeliveryAddressCard(
                name: address['name'],
                phone: address['phone'],
                type: address['type'],
                typeIcon: address['typeIcon'],
                typeColor: address['typeColor'],
                isDefault: address['isDefault'],
                fastDelivery: address['fastDelivery'],
                address: address['address'],
                extraTags: address['extraTags'],
                isSelected: _selectedIndex == index,
                onTap: () => setState(() => _selectedIndex = index),
              );
            },
          ),
          
          // Sticky Bottom Section
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomActionSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionSection() {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DeliveryInfoCard(),
            SizedBox(height: 16.h),
            _buildDeliverHereButton(),
            const SecureDeliveryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverHereButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPurple.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_rounded, color: Colors.white, size: 20.sp),
          SizedBox(width: 10.w),
          Text(
            "Deliver Here",
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
