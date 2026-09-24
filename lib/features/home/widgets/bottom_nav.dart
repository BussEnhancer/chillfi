import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/features/categories/categories_screen.dart';
import 'package:chillfi/features/home/home_dashboard_screen.dart';
import 'package:chillfi/features/orders/my_orders_screen.dart';
import 'package:chillfi/features/profile/my_profile_screen.dart';
import 'package:chillfi/features/wishlist/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const CustomBottomNavBar({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_rounded, 'Home', 0),
          _buildNavItem(context, Icons.grid_view_rounded, 'Categories', 1),
          _buildNavItem(context, Icons.shopping_bag_outlined, 'Orders', 2),
          _buildNavItem(context, Icons.favorite_rounded, 'Wishlist', 3),
          _buildNavItem(context, Icons.person_outline_rounded, 'Account', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    bool isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        // Tapping the active tab does nothing — except Home from a screen pushed on top of Home.
        if (isActive && !(index == 0 && Navigator.canPop(context))) return;
        Widget nextScreen;
        switch (index) {
          case 0:
            nextScreen = const HomeDashboardScreen();
            break;
          case 1:
            nextScreen = const CategoriesScreen();
            break;
          case 2:
            nextScreen = const MyOrdersScreen(asTab: true);
            break;
          case 3:
            nextScreen = const WishlistScreen();
            break;
          case 4:
            nextScreen = const MyProfileScreen();
            break;
          default:
            return;
        }

        // Keep Home at the base of the stack: every other tab sits on top of it, so Back from a tab
        // returns Home (instead of exiting the app or popping to a blank screen).
        final navigator = Navigator.of(context);
        navigator.pushAndRemoveUntil(
          PageRouteBuilder(pageBuilder: (_, _, _) => const HomeDashboardScreen(), transitionDuration: Duration.zero),
          (_) => false,
        );
        if (index != 0) {
          navigator.push(PageRouteBuilder(pageBuilder: (_, _, _) => nextScreen, transitionDuration: Duration.zero));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.secondaryPurple : AppColors.greyText,
                size: 24.sp,
              ),
              if (index == 3)
                Consumer<WishlistProvider>(
                  builder: (context, wishlist, _) {
                    final count = wishlist.items.length;
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      top: -5,
                      right: -5,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(color: AppColors.secondaryPurple, shape: BoxShape.circle),
                        child: Text('$count', style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.secondaryPurple : AppColors.greyText,
            ),
          ),
          if (isActive)
            Container(
              margin: EdgeInsets.only(top: 4.h),
              width: 4.w,
              height: 4.w,
              decoration: const BoxDecoration(
                color: AppColors.secondaryPurple,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
