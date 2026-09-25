import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/cart_model.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/features/address/add_new_address_screen.dart';
import 'package:chillfi/features/address/widgets/saved_address_widgets.dart';
import 'package:chillfi/core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

({Color color, IconData badge, IconData category}) _styleForLabel(String label) {
  switch (label) {
    case 'Work':
      return (color: Colors.blue, badge: Icons.business_center_rounded, category: Icons.business_rounded);
    case 'Other':
      return (color: Colors.purple, badge: Icons.star_rounded, category: Icons.location_on_rounded);
    default:
      return (color: Colors.green, badge: Icons.home_rounded, category: Icons.home_rounded);
  }
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadAddresses();
    });
  }

  Future<void> _addNew() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddNewAddressScreen()),
    );
    if (result == true && mounted) context.read<CartProvider>().loadAddresses();
  }

  Future<void> _edit(AddressModel address) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddNewAddressScreen(existing: address)),
    );
    if (result == true && mounted) context.read<CartProvider>().loadAddresses();
  }

  Future<void> _delete(AddressModel address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Remove "${address.label}" address?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<CartProvider>().deleteAddress(address.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60.w,
        leading: Padding(padding: EdgeInsets.only(left: 16.w), child: const AppBackButton()),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Saved Addresses",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
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
            child: GestureDetector(
              onTap: _addNew,
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
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                const AddressInfoBanner(),
                SizedBox(height: 24.h),
                ...cart.addresses.map((address) {
                  final style = _styleForLabel(address.label);
                  final landmark = [
                    if (address.line2 != null && address.line2!.isNotEmpty) address.line2,
                    '${address.city}, ${address.state} - ${address.pincode}',
                  ].join('\n');
                  return SavedAddressCard(
                    label: address.label,
                    address: address.line1,
                    landmark: landmark,
                    contactName: address.name,
                    phoneNumber: address.phone,
                    categoryColor: style.color,
                    badgeIcon: style.badge,
                    categoryIcon: style.category,
                    isDefault: address.isDefault,
                    onEdit: () => _edit(address),
                    onDelete: () => _delete(address),
                    onSetDefault: () => context.read<CartProvider>().setDefaultAddress(address.id),
                  );
                }),
                const SecurityBannerCard(),
                SizedBox(height: 40.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
