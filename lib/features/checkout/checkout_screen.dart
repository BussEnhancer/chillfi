import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/cart_model.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/features/payment/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadAddresses();
    });
  }

  void _addAddress() {
    _showAddressForm(context, null);
  }

  void _editAddress(AddressModel address) {
    _showAddressForm(context, address);
  }

  void _showAddressForm(BuildContext ctx, AddressModel? existing) {
    final nameC = TextEditingController(text: existing?.name);
    final phoneC = TextEditingController(text: existing?.phone);
    final line1C = TextEditingController(text: existing?.line1);
    final line2C = TextEditingController(text: existing?.line2);
    final cityC = TextEditingController(text: existing?.city);
    final stateC = TextEditingController(text: existing?.state);
    final pinC = TextEditingController(text: existing?.pincode);
    String label = existing?.label ?? 'Home';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => StatefulBuilder(builder: (ctx2, setS) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(existing == null ? 'Add Address' : 'Edit Address',
                    style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                SizedBox(height: 16.h),
                // Label chips
                Row(
                  children: ['Home', 'Work', 'Other'].map((l) => GestureDetector(
                    onTap: () => setS(() => label = l),
                    child: Container(
                      margin: EdgeInsets.only(right: 10.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: label == l ? AppColors.secondaryPurple : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(l, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: label == l ? Colors.white : AppColors.greyText)),
                    ),
                  )).toList(),
                ),
                SizedBox(height: 16.h),
                _field(nameC, 'Full Name'),
                _field(phoneC, 'Phone Number', keyboardType: TextInputType.phone),
                _field(line1C, 'Address Line 1'),
                _field(line2C, 'Address Line 2 (Optional)'),
                Row(children: [
                  Expanded(child: _field(cityC, 'City')),
                  SizedBox(width: 12.w),
                  Expanded(child: _field(stateC, 'State')),
                ]),
                _field(pinC, 'Pincode', keyboardType: TextInputType.number),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      final cart = context.read<CartProvider>();
                      final body = {
                        'label': label,
                        'name': nameC.text.trim(),
                        'phone': phoneC.text.trim(),
                        'line1': line1C.text.trim(),
                        'line2': line2C.text.trim(),
                        'city': cityC.text.trim(),
                        'state': stateC.text.trim(),
                        'pincode': pinC.text.trim(),
                      };
                      final err = await cart.saveAddress(body, existingId: existing?.id);
                      if (err == null && ctx2.mounted) Navigator.pop(ctx2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text('Save Address', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _field(TextEditingController c, String hint, {TextInputType? keyboardType}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cart, _) {
      final s = cart.summary;
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 22.sp),
          ),
          title: Text('Checkout', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 140.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address
                  _SectionHeader(title: 'Delivery Address', action: 'Add New', onAction: _addAddress),
                  SizedBox(height: 10.h),

                  if (cart.addressState == CartLoadState.loading)
                    const Center(child: CircularProgressIndicator(color: AppColors.secondaryPurple))
                  else if (cart.addresses.isEmpty)
                    _EmptyAddressCard(onAdd: _addAddress)
                  else
                    ...cart.addresses.map((addr) => _AddressCard(
                          address: addr,
                          isSelected: cart.selectedAddress?.id == addr.id,
                          onSelect: () => cart.selectAddress(addr),
                          onEdit: () => _editAddress(addr),
                          onDelete: () => cart.deleteAddress(addr.id),
                        )),

                  SizedBox(height: 20.h),

                  // Order Summary
                  _SectionHeader(title: 'Order Summary (${s.itemCount} items)'),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
                    child: Column(
                      children: [
                        ...cart.items.map((item) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text('${item.name} × ${item.quantity}',
                                        style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                  Text('₹${item.lineTotal.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                                ],
                              ),
                            )),
                        Divider(height: 20.h, color: const Color(0xFFEEEEEE)),
                        _summaryRow('Subtotal', '₹${s.subtotal.toStringAsFixed(0)}'),
                        if (s.savings > 0) _summaryRow('Discount', '-₹${s.savings.toStringAsFixed(0)}', green: true),
                        if (cart.couponDiscount > 0) _summaryRow('Coupon', '-₹${cart.couponDiscount.toStringAsFixed(0)}', green: true),
                        _summaryRow('Delivery', s.deliveryFee == 0 ? 'FREE' : '₹${s.deliveryFee.toStringAsFixed(0)}', green: s.deliveryFee == 0),
                        if (s.taxAmount > 0) _summaryRow('GST', '₹${s.taxAmount.toStringAsFixed(0)}'),
                        Divider(height: 20.h, color: const Color(0xFFEEEEEE)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                            Text('₹${(s.total - cart.couponDiscount).toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Proceed button
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5))],
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: cart.selectedAddress == null
                          ? null
                          : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryPurple,
                        disabledBackgroundColor: AppColors.greyText,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: Text(
                        cart.selectedAddress == null ? 'Select Delivery Address' : 'Proceed to Payment',
                        style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryRow(String label, String value, {bool green = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: green ? Colors.green : AppColors.darkText)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.secondaryPurple)),
          ),
      ],
    );
  }
}

class _EmptyAddressCard extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyAddressCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.3), style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.add_location_alt_outlined, color: AppColors.secondaryPurple, size: 36.sp),
            SizedBox(height: 8.h),
            Text('Add Delivery Address', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.secondaryPurple)),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({required this.address, required this.isSelected, required this.onSelect, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isSelected ? AppColors.secondaryPurple : Colors.transparent, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.secondaryPurple : AppColors.greyText, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(address.name, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(color: AppColors.secondaryPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4.r)),
                        child: Text(address.label, style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.secondaryPurple, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(address.phone, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText)),
                  SizedBox(height: 2.h),
                  Text(address.fullAddress, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText), maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      GestureDetector(onTap: onEdit, child: Text('Edit', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.secondaryPurple))),
                      SizedBox(width: 16.w),
                      GestureDetector(onTap: onDelete, child: Text('Delete', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.red.shade400))),
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
}
