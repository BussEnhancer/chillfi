import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/cart_model.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/features/address/add_new_address_screen.dart';
import 'package:chillfi/features/address/widgets/delivery_address_card.dart';
import 'package:chillfi/features/address/widgets/delivery_bottom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

({IconData icon, Color color}) _typeStyle(String label) {
  switch (label) {
    case 'Work':
      return (icon: Icons.business_rounded, color: Colors.orange);
    case 'Other':
      return (icon: Icons.favorite_rounded, color: Colors.pink);
    default:
      return (icon: Icons.home_rounded, color: AppColors.secondaryPurple);
  }
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  AddressModel? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cart = context.read<CartProvider>();
      await cart.loadAddresses();
      if (mounted) setState(() => _selected = cart.selectedAddress);
    });
  }

  Future<void> _addNew() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNewAddressScreen()),
    );
    if (result == true && mounted) context.read<CartProvider>().loadAddresses();
  }

  void _deliverHere() {
    if (_selected == null) return;
    context.read<CartProvider>().selectAddress(_selected!);
    Navigator.pop(context, _selected);
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
            onTap: _addNew,
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
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.addressState == CartLoadState.loading && cart.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cart.addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(40.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_off_rounded, size: 48.sp, color: AppColors.greyText.withValues(alpha: 0.3)),
                    SizedBox(height: 16.h),
                    Text('No saved addresses yet', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _addNew,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryPurple, foregroundColor: Colors.white),
                      child: const Text('Add Address'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                physics: const BouncingScrollPhysics(),
                itemCount: cart.addresses.length,
                itemBuilder: (context, index) {
                  final address = cart.addresses[index];
                  final style = _typeStyle(address.label);
                  final fullAddress = [
                    address.line1,
                    if (address.line2 != null && address.line2!.isNotEmpty) address.line2,
                    '${address.city}, ${address.state}, India',
                  ].join(', ');
                  return DeliveryAddressCard(
                    name: address.name,
                    phone: address.phone,
                    type: address.label.toUpperCase(),
                    typeIcon: style.icon,
                    typeColor: style.color,
                    isDefault: address.isDefault,
                    fastDelivery: true,
                    address: fullAddress,
                    extraTags: const [],
                    isSelected: _selected?.id == address.id,
                    onTap: () => setState(() => _selected = address),
                  );
                },
              ),

              // Sticky Bottom Section
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomActionSection(),
              ),
            ],
          );
        },
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
    final enabled = _selected != null;
    return GestureDetector(
      onTap: enabled ? _deliverHere : null,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.purpleGradient : null,
          color: enabled ? null : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.secondaryPurple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
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
      ),
    );
  }
}
