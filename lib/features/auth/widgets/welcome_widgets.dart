import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  const WelcomeFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104.w,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
              height: 1.2,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 7.sp,
              color: AppColors.greyText,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductShowcase extends StatelessWidget {
  final Animation<double> floatingAnimation;

  const ProductShowcase({super.key, required this.floatingAnimation});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160.h, // Reduced height
      width: 1.sw,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Podium
          Positioned(
            bottom: 10.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outline Shadow
                Container(
                  width: 240.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.elliptical(240.w, 35.h)),
                    border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2), width: 2),
                  ),
                ),
                // Main Podium
                Container(
                  width: 230.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.elliptical(230.w, 30.h)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Products
          AnimatedBuilder(
            animation: floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, floatingAnimation.value),
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Laptop (Background)
                Positioned(
                  bottom: 30.h,
                  child: Icon(Icons.laptop_mac_rounded, size: 100.sp, color: Colors.grey[800]),
                ),
                // Headphones
                Positioned(
                  bottom: 35.h,
                  left: 60.w,
                  child: Icon(Icons.headset_rounded, size: 60.sp, color: Colors.black),
                ),
                // Smartphone
                Positioned(
                  bottom: 25.h,
                  left: 120.w,
                  child: Container(
                    width: 35.w,
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: Colors.purple[200],
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                  ),
                ),
                // Smartwatch
                Positioned(
                  bottom: 30.h,
                  right: 80.w,
                  child: Icon(Icons.watch_rounded, size: 40.sp, color: Colors.black),
                ),
                // Charger
                Positioned(
                  bottom: 30.h,
                  right: 60.w,
                  child: Icon(Icons.power_rounded, size: 25.sp, color: Colors.grey[400]),
                ),
                // Shopping Bag (CHILLFI)
                Positioned(
                  bottom: 45.h,
                  left: 40.w,
                  child: Container(
                    width: 30.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryPurple,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                      child: Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 16.sp),
                    ),
                  ),
                ),
                // Floating Cart
                Positioned(
                  top: 20.h,
                  right: 40.w,
                  child: Icon(Icons.shopping_cart_rounded, color: AppColors.primaryOrange.withOpacity(0.6), size: 24.sp),
                ),
                // Decorative Spheres
                Positioned(
                  top: 40.h,
                  left: 70.w,
                  child: _buildOrb(10, AppColors.primaryOrange),
                ),
                Positioned(
                  bottom: 80.h,
                  right: 70.w,
                  child: _buildOrb(8, AppColors.secondaryPurple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }
}

class WelcomeSecondaryButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const WelcomeSecondaryButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 1.sw,
        height: 52.h, // Reduced height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.secondaryPurple, width: 1.5),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: AppColors.secondaryPurple,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
