import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/address/widgets/add_address_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  int _selectedTypeIndex = 0;
  bool _isDefault = true;

  final List<Map<String, dynamic>> _addressTypes = [
    {'label': 'Home', 'icon': Icons.home_rounded},
    {'label': 'Work', 'icon': Icons.business_rounded},
    {'label': 'Other', 'icon': Icons.favorite_rounded},
    {'label': 'Pick-up Point', 'icon': Icons.storefront_rounded},
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
              "Add New Address",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "Add a new delivery address",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                
                // Address Type Selection
                AddressSectionCard(
                  title: "Address Type",
                  subtitle: "Select the type of address",
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(_addressTypes.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: AddressTypeCard(
                            label: _addressTypes[index]['label'],
                            icon: _addressTypes[index]['icon'],
                            isSelected: _selectedTypeIndex == index,
                            onTap: () => setState(() => _selectedTypeIndex = index),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // Contact Details
                AddressSectionCard(
                  title: "Contact Details",
                  child: Row(
                    children: [
                      Expanded(
                        child: const CustomAddressField(
                          label: "Full Name",
                          hint: "Enter full name",
                          isRequired: true,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: const CustomAddressField(
                          label: "Mobile Number",
                          hint: "Enter mobile number",
                          isRequired: true,
                        ),
                      ),
                    ],
                  ),
                ),

                // Address Details
                AddressSectionCard(
                  title: "Address Details",
                  child: Column(
                    children: [
                      const CustomAddressField(
                        label: "House / Flat / Building",
                        hint: "Enter house, flat, building name",
                        isRequired: true,
                      ),
                      SizedBox(height: 16.h),
                      const CustomAddressField(
                        label: "Area / Street / Sector",
                        hint: "Enter area, street, sector",
                        isRequired: true,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: const CustomAddressField(
                              label: "Landmark",
                              hint: "Enter landmark",
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            flex: 1,
                            child: CustomAddressField(
                              label: "Pincode",
                              hint: "Enter 6 digit pincode",
                              isRequired: true,
                              suffix: GestureDetector(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Text(
                                      "Detect Location",
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondaryPurple,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(Icons.my_location_rounded, color: AppColors.secondaryPurple, size: 14.sp),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: const CustomDropdownField(
                              label: "City / Town",
                              value: "Select city",
                              isRequired: true,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: const CustomDropdownField(
                              label: "State",
                              value: "Select state",
                              isRequired: true,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: const CustomDropdownField(
                              label: "Country",
                              value: "India",
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Save Address Options
                AddressSectionCard(
                  title: "Save Address As",
                  subtitle: "Set as default address",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoSwitch(
                        value: _isDefault,
                        activeTrackColor: const Color(0xFF22C55E),
                        onChanged: (val) => setState(() => _isDefault = val),
                      ),
                    ],
                  ),
                ),

                const SecurityInfoCard(),
                SizedBox(height: 140.h), // Space for bottom buttons
              ],
            ),
          ),

          // Bottom Buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomActions(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
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
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 56.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.secondaryPurple, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryPurple,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
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
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_rounded, color: Colors.white, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        "Save Address",
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
