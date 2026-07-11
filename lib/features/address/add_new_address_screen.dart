import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/cart_model.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/features/address/widgets/add_address_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddNewAddressScreen extends StatefulWidget {
  final AddressModel? existing;
  const AddNewAddressScreen({super.key, this.existing});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  int _selectedTypeIndex = 0;
  bool _isDefault = true;
  bool _saving = false;
  String? _error;

  late final _nameC = TextEditingController(text: widget.existing?.name);
  late final _phoneC = TextEditingController(text: widget.existing?.phone);
  late final _line1C = TextEditingController(text: widget.existing?.line1);
  late final _line2C = TextEditingController(text: widget.existing?.line2);
  late final _cityC = TextEditingController(text: widget.existing?.city);
  late final _stateC = TextEditingController(text: widget.existing?.state);
  late final _pinC = TextEditingController(text: widget.existing?.pincode);

  final List<Map<String, dynamic>> _addressTypes = [
    {'label': 'Home', 'icon': Icons.home_rounded},
    {'label': 'Work', 'icon': Icons.business_rounded},
    {'label': 'Other', 'icon': Icons.favorite_rounded},
    {'label': 'Pick-up Point', 'icon': Icons.storefront_rounded},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final idx = _addressTypes.indexWhere((t) => t['label'] == widget.existing!.label);
      _selectedTypeIndex = idx >= 0 ? idx : 0;
      _isDefault = widget.existing!.isDefault;
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _line1C.dispose();
    _line2C.dispose();
    _cityC.dispose();
    _stateC.dispose();
    _pinC.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_nameC.text.trim().isEmpty ||
        _phoneC.text.trim().isEmpty ||
        _line1C.text.trim().isEmpty ||
        _cityC.text.trim().isEmpty ||
        _stateC.text.trim().isEmpty ||
        _pinC.text.trim().isEmpty) {
      setState(() => _error = 'Please fill all required fields');
      return;
    }
    setState(() { _saving = true; _error = null; });

    final body = {
      'label': _addressTypes[_selectedTypeIndex]['label'],
      'name': _nameC.text.trim(),
      'phone': _phoneC.text.trim(),
      'line1': _line1C.text.trim(),
      'line2': _line2C.text.trim(),
      'city': _cityC.text.trim(),
      'state': _stateC.text.trim(),
      'pincode': _pinC.text.trim(),
      'is_default': _isDefault,
    };

    final err = await context.read<CartProvider>().saveAddress(body, existingId: widget.existing?.id);
    if (!mounted) return;
    setState(() => _saving = false);
    if (err == null) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = err);
    }
  }

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
              widget.existing == null ? "Add New Address" : "Edit Address",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              widget.existing == null ? "Add a new delivery address" : "Update your delivery address",
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
                        child: CustomAddressField(
                          label: "Full Name",
                          hint: "Enter full name",
                          isRequired: true,
                          controller: _nameC,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomAddressField(
                          label: "Mobile Number",
                          hint: "Enter mobile number",
                          isRequired: true,
                          controller: _phoneC,
                          keyboardType: TextInputType.phone,
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
                      CustomAddressField(
                        label: "House / Flat / Building",
                        hint: "Enter house, flat, building name",
                        isRequired: true,
                        controller: _line1C,
                      ),
                      SizedBox(height: 16.h),
                      CustomAddressField(
                        label: "Area / Street / Sector",
                        hint: "Enter area, street, sector",
                        controller: _line2C,
                      ),
                      SizedBox(height: 16.h),
                      CustomAddressField(
                        label: "Pincode",
                        hint: "Enter 6 digit pincode",
                        isRequired: true,
                        controller: _pinC,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: CustomAddressField(
                              label: "City / Town",
                              hint: "Enter city",
                              isRequired: true,
                              controller: _cityC,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: CustomAddressField(
                              label: "State",
                              hint: "Enter state",
                              isRequired: true,
                              controller: _stateC,
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

                if (_error != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Text(
                      _error!,
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red, fontWeight: FontWeight.w600),
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
                onTap: _saving ? null : () => Navigator.pop(context),
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
                onTap: _saving ? null : _handleSave,
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
                  child: _saving
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
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
