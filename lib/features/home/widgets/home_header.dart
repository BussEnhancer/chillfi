import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/features/address/delivery_address_screen.dart';
import 'package:chillfi/features/auth/login_screen.dart';
import 'package:chillfi/features/cart/cart_screen.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/features/profile/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. DELIVERY LOCATION — opens the address picker (login for guests)
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final loggedIn = context.read<AuthProvider>().isAuthenticated;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => loggedIn
                        ? const DeliveryAddressScreen()
                        : const LoginScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primaryOrange,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deliver to',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Consumer<CartProvider>(
                          builder: (context, cart, _) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  cart.selectedAddress != null
                                      ? '${cart.selectedAddress!.label} - ${cart.selectedAddress!.pincode}'
                                      : (context
                                                .watch<AuthProvider>()
                                                .isAuthenticated
                                            ? (cart.addressState == CartLoadState.loading ? 'Loading…' : 'Add address')
                                            : 'Set location'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16.sp,
                                color: AppColors.darkText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // 2. LOGO
          Image.asset(
            'assets/images/logo_color.png',
            width: 70.w,
            height: 35.h,
            fit: BoxFit.contain,
          ),

          // 3. ACTIONS
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              final cartCount = cart.summary.itemCount;
              return Row(
                children: [
                  _buildBadgeIcon(
                    Icons.notifications_none_rounded,
                    context.watch<WishlistProvider>().unreadNotificationCount,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 12.w),
                  _buildBadgeIcon(
                    Icons.shopping_cart_outlined,
                    cartCount,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeIcon(IconData icon, int count, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.darkText, size: 22.sp),
          ),
          if (count > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryPurple,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
