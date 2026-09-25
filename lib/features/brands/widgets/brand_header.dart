import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/features/cart/cart_screen.dart';
import 'package:chillfi/features/search/search_screen.dart';
import 'package:chillfi/core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: Colors.white,
      child: Row(
        children: [
          const AppBackButton(),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "All Brands",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Find your favorite brand",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
            icon: Icon(Icons.search_rounded, color: AppColors.darkText, size: 24.sp),
          ),
          Consumer<CartProvider>(
            builder: (context, cart, _) => Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                  icon: Icon(Icons.shopping_cart_outlined, color: AppColors.darkText, size: 24.sp),
                ),
                if (cart.cartCount > 0)
                  Positioned(
                    right: 8.w,
                    top: 8.h,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.cartCount}',
                        style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
