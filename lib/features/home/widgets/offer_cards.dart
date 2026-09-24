import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/cart_model.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/features/auth/login_screen.dart';
import 'package:chillfi/features/offers/offers_products_screen.dart';
import 'package:chillfi/features/orders/my_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OfferCardsSection extends StatelessWidget {
  const OfferCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.user?.name?.split(' ').first ?? 'there';
    final isGuest = auth.user == null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        children: [
          // Welcome card — real shortcut: track orders (signed in) or sign in (guest)
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => isGuest ? const LoginScreen() : const MyOrdersScreen(),
              )),
              child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryPurple.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10.w,
                    bottom: -10.h,
                    child: Icon(isGuest ? Icons.person_rounded : Icons.inventory_2_rounded, size: 80.sp, color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGuest ? 'Welcome! 👋' : 'Hey, $userName! 👋',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          isGuest ? 'Sign in for faster checkout' : 'Welcome back',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(isGuest ? Icons.login_rounded : Icons.local_shipping_rounded, color: Colors.amber, size: 20.sp),
                            SizedBox(width: 6.w),
                            Text(
                              isGuest ? 'Sign in' : 'My Orders',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16.sp),
                          ],
                        ),
                        Text(
                          isGuest ? 'Orders, wishlist & addresses' : 'Track & manage orders',
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          // Exclusive Offer Card — driven by the best real active coupon
          Expanded(child: Consumer<CartProvider>(builder: (context, cart, _) => _couponCard(context, cart.activeCoupons))),
        ],
      ),
    );
  }

  Widget _couponCard(BuildContext context, List<CouponModel> coupons) {
    CouponModel? best;
    for (final c in coupons) {
      if (best == null || (c.type == best.type ? c.value > best.value : c.type == 'Percentage')) best = c;
    }
    final String headline;
    final String sub;
    if (best == null) {
      headline = "Today's Deals";
      sub = 'Big savings on top brands';
    } else {
      headline = best.type == 'Percentage' ? 'Extra ${best.value.toStringAsFixed(0)}% OFF' : '₹${best.value.toStringAsFixed(0)} OFF';
      sub = best.minOrder > 0 ? 'On orders above ₹${best.minOrder.toStringAsFixed(0)}' : 'On any order';
    }
    final code = best?.code;
    return GestureDetector(
      onTap: code == null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OffersProductsScreen())) : null,
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F0),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.1)),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 10.w,
              top: 20.h,
              child: Icon(Icons.confirmation_num_rounded, size: 60.sp, color: AppColors.primaryOrange.withValues(alpha: 0.2)),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exclusive Offer',
                      style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.primaryOrange)),
                  SizedBox(height: 4.h),
                  Text(headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                  Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.greyText)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (code == null) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const OffersProductsScreen()));
                        return;
                      }
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Coupon code $code copied!'), duration: const Duration(seconds: 2)),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(code == null ? 'View deals' : 'Code: $code',
                              style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w700, color: AppColors.primaryOrange)),
                          SizedBox(width: 4.w),
                          Icon(code == null ? Icons.chevron_right_rounded : Icons.copy_rounded, size: 10.sp, color: AppColors.primaryOrange),
                        ],
                      ),
                    ),
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
