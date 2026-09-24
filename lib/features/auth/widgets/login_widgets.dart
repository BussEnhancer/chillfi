import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language_rounded, size: 18.sp, color: AppColors.secondaryPurple),
          SizedBox(width: 8.w),
          Text(
            'English',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp, color: AppColors.greyText),
        ],
      ),
    );
  }
}

class PremiumPhoneInput extends StatefulWidget {
  final TextEditingController? controller;
  const PremiumPhoneInput({super.key, this.controller});

  @override
  State<PremiumPhoneInput> createState() => _PremiumPhoneInputState();
}

class _PremiumPhoneInputState extends State<PremiumPhoneInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.fieldBorder.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 14.w),
          Row(
            children: [
              Image.asset('assets/images/india_flag.png', width: 24.w, errorBuilder: (c,e,s) => Text('🇮🇳', style: TextStyle(fontSize: 18.sp))),
              SizedBox(width: 8.w),
              Text(
                '+91',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          VerticalDivider(
            color: AppColors.fieldBorder,
            indent: 14.h,
            endIndent: 14.h,
            thickness: 1,
            width: 24.w,
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
              decoration: InputDecoration(
                hintText: 'Mobile Number',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  color: AppColors.greyText.withValues(alpha: 0.4),
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
        height: 58.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8549), Color(0xFFFF6B2C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Positioned(
              right: 20.w,
              child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16.sp),
            ),
          ],
        ),
      ),
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

class HeaderCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = AppColors.primaryOrange;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.9,
      0,
      size.height * 0.65,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
