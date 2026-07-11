import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/features/orders/order_success_screen.dart';
import 'package:chillfi/features/payment/phonepe_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selected = 'COD';
  bool _placing = false;

  Future<void> _proceed() async {
    setState(() => _placing = true);
    final cart = context.read<CartProvider>();

    if (_selected == 'COD') {
      final order = await cart.placeOrder(paymentMethod: 'COD');
      if (!mounted) return;
      if (order != null) {
        await cart.confirmCOD(order.id);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
          (route) => route.isFirst,
        );
      } else {
        _showError('Failed to place order. Please try again.');
      }
    } else {
      // PhonePe
      final order = await cart.placeOrder(paymentMethod: 'PhonePe');
      if (!mounted) return;
      if (order != null) {
        final payData = await cart.initiatePhonePePayment(order.id);
        if (!mounted) return;
        if (payData != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PhonePePaymentScreen(orderId: order.id, paymentUrl: payData['payment_url'] ?? '')));
        } else {
          _showError('Could not initiate payment. Try COD.');
        }
      } else {
        _showError('Failed to place order.');
      }
    }
    if (mounted) setState(() => _placing = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
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
          title: Text('Payment', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 140.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Payment Method', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                  SizedBox(height: 12.h),

                  _PaymentOption(
                    value: 'COD',
                    selected: _selected,
                    icon: Icons.money_rounded,
                    title: 'Cash on Delivery',
                    subtitle: 'Pay when your order arrives',
                    onTap: () => setState(() => _selected = 'COD'),
                  ),
                  SizedBox(height: 10.h),
                  _PaymentOption(
                    value: 'PhonePe',
                    selected: _selected,
                    icon: Icons.phone_android_rounded,
                    title: 'PhonePe / UPI',
                    subtitle: 'Pay via UPI, Credit / Debit Card',
                    onTap: () => setState(() => _selected = 'PhonePe'),
                  ),

                  SizedBox(height: 20.h),
                  // Order total card
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
                    child: Column(
                      children: [
                        _row('Items (${s.itemCount})', '₹${s.subtotal.toStringAsFixed(0)}'),
                        if (s.savings > 0) _row('Discount', '-₹${s.savings.toStringAsFixed(0)}', green: true),
                        if (cart.couponDiscount > 0) _row('Coupon', '-₹${cart.couponDiscount.toStringAsFixed(0)}', green: true),
                        _row('Delivery', s.deliveryFee == 0 ? 'FREE' : '₹${s.deliveryFee.toStringAsFixed(0)}', green: s.deliveryFee == 0),
                        Divider(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total to Pay', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                            Text('₹${s.total.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: _placing ? null : _proceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: _placing
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : Text(
                              _selected == 'COD' ? 'Place Order (COD)' : 'Pay ₹${s.total.toStringAsFixed(0)}',
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

  Widget _row(String label, String value, {bool green = false}) {
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

class _PaymentOption extends StatelessWidget {
  final String value;
  final String selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentOption({required this.value, required this.selected, required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isSelected ? AppColors.secondaryPurple : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondaryPurple.withOpacity(0.1) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: isSelected ? AppColors.secondaryPurple : AppColors.greyText, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText)),
                ],
              ),
            ),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.secondaryPurple : AppColors.greyText, size: 22.sp),
          ],
        ),
      ),
    );
  }
}
