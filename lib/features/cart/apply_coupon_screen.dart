import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/cart_model.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ApplyCouponScreen extends StatefulWidget {
  const ApplyCouponScreen({super.key});

  @override
  State<ApplyCouponScreen> createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends State<ApplyCouponScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadActiveCoupons();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply(String code) async {
    if (code.trim().isEmpty) return;
    setState(() { _loading = true; _error = null; });
    final cart = context.read<CartProvider>();
    final err = await cart.applyCoupon(code.trim().toUpperCase());
    setState(() => _loading = false);
    if (err == null) {
      if (mounted) Navigator.pop(context);
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 22.sp),
        ),
        title: Text('Apply Coupon', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
      ),
      body: Consumer<CartProvider>(builder: (context, cart, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText),
                        errorText: _error,
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: _loading ? null : () => _apply(_controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: _loading
                        ? SizedBox(width: 20.w, height: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Apply', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14.sp)),
                  ),
                ],
              ),

              if (cart.activeCoupons.isNotEmpty) ...[
                SizedBox(height: 28.h),
                Text('Available Coupons', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                SizedBox(height: 14.h),
                ...cart.activeCoupons.map((c) => _CouponCard(coupon: c, onApply: () => _apply(c.code))),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final VoidCallback onApply;

  const _CouponCard({required this.coupon, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: AppColors.secondaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
            child: Icon(Icons.local_offer_rounded, color: AppColors.secondaryPurple, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.secondaryPurple, width: 1.5),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(coupon.code, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.secondaryPurple, letterSpacing: 1)),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onApply,
                      child: Text('Apply', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.secondaryPurple)),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(coupon.description, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                SizedBox(height: 4.h),
                Text('Min order ₹${coupon.minOrder.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
