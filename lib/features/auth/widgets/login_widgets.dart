import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language_rounded, size: 16.sp, color: AppColors.greyText),
          SizedBox(width: 6.w),
          Text(
            'English',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16.sp, color: AppColors.greyText),
        ],
      ),
    );
  }
}

class PremiumPhoneInput extends StatelessWidget {
  const PremiumPhoneInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          // Country Flag & Code
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2.r),
                child: Text('🇮🇳', style: TextStyle(fontSize: 14.sp)),
              ),
              SizedBox(width: 6.w),
              Text(
                '+91',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp, color: AppColors.greyText),
            ],
          ),
          VerticalDivider(
            color: AppColors.fieldBorder,
            indent: 12.h,
            endIndent: 12.h,
            thickness: 1,
            width: 24.w,
          ),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.phone,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
              decoration: InputDecoration(
                hintText: 'Enter Mobile Number',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.greyText.withOpacity(0.6),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const PrimaryGradientButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Positioned(
              right: 20.w,
              child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class WhatsAppButton extends StatelessWidget {
  final VoidCallback onTap;
  const WhatsAppButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.secondaryPurple, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_rounded, color: AppColors.secondaryPurple, size: 22.sp),
            SizedBox(width: 10.w),
            Flexible(
              child: Text(
                'Login with WhatsApp',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DottedPattern extends StatelessWidget {
  final int rows;
  final int cols;
  final Color color;

  const DottedPattern({
    super.key,
    required this.rows,
    required this.cols,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rows, (r) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(cols, (c) {
            return Container(
              width: 3.r,
              height: 3.r,
              margin: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      }),
    );
  }
}

class ProductComposition extends StatelessWidget {
  const ProductComposition({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        height: 180.h,
        width: 250.w,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Podium
            Container(
              width: 240.w,
              height: 30.h,
              margin: EdgeInsets.only(bottom: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.elliptical(240.w, 30.h)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
            Container(
              width: 250.w,
              height: 40.h,
              margin: EdgeInsets.only(bottom: 5.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryOrange.withOpacity(0.15), width: 1.5),
                borderRadius: BorderRadius.all(Radius.elliptical(250.w, 40.h)),
              ),
            ),
            
            // Products (Mocked using Icons/Containers)
            Positioned(
              bottom: 30.h,
              right: 40.w,
              child: _buildShoppingBag(),
            ),
            Positioned(
              bottom: 30.h,
              left: 50.w,
              child: Icon(Icons.headset_rounded, size: 70.sp, color: AppColors.black),
            ),
            Positioned(
              bottom: 25.h,
              right: 85.w,
              child: _buildSmartphone(),
            ),
            Positioned(
              bottom: 25.h,
              right: 70.w,
              child: Icon(Icons.watch_rounded, size: 35.sp, color: AppColors.black),
            ),
            
            // Floating Spheres
            Positioned(
              top: 40.h,
              right: 20.w,
              child: _buildOrb(12, AppColors.secondaryPurple),
            ),
            Positioned(
              bottom: 60.h,
              left: 30.w,
              child: _buildOrb(8, AppColors.primaryOrange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingBag() {
    return Container(
      width: 60.w,
      height: 75.h,
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            'CHILLFI',
            style: GoogleFonts.poppins(
              fontSize: 8.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartphone() {
    return Container(
      width: 32.w,
      height: 65.h,
      decoration: BoxDecoration(
        color: AppColors.secondaryPurple,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Center(
        child: Container(
          width: 2.w,
          height: 2.w,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
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
            color: color.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }
}

class HeaderCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = AppColors.primaryOrange;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height,
      size.width * 0.4,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.6,
      0,
      size.height * 0.75,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
