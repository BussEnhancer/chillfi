import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordIllustration extends StatefulWidget {
  const ForgotPasswordIllustration({super.key});

  @override
  State<ForgotPasswordIllustration> createState() => _ForgotPasswordIllustrationState();
}

class _ForgotPasswordIllustrationState extends State<ForgotPasswordIllustration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Container(
          height: 180.h,
          width: 220.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Decorative Leaves/Shapes
              Positioned(
                left: 20.w,
                bottom: 40.h,
                child: _buildLeaf(45, AppColors.secondaryPurple.withOpacity(0.1)),
              ),
              Positioned(
                right: 20.w,
                top: 40.h,
                child: _buildLeaf(-30, AppColors.primaryOrange.withOpacity(0.1)),
              ),

              // Smartphone Illustration
              Transform.translate(
                offset: Offset(0, -_floatAnimation.value),
                child: Container(
                  width: 100.w,
                  height: 160.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.fieldBorder, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 8.h),
                      Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.fieldBorder, borderRadius: BorderRadius.circular(2))),
                      const Spacer(),
                      Icon(Icons.lock_person_rounded, size: 40.sp, color: AppColors.secondaryPurple.withOpacity(0.2)),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (i) => Container(margin: EdgeInsets.symmetric(horizontal: 2.w), width: 6.r, height: 6.r, decoration: const BoxDecoration(color: AppColors.fieldBorder, shape: BoxShape.circle))),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),

              // Floating Lock
              Positioned(
                left: 10.w,
                bottom: 20.h,
                child: Transform.translate(
                  offset: Offset(0, _floatAnimation.value * 0.5),
                  child: _build3DLock(),
                ),
              ),

              // Key Object
              Positioned(
                right: 40.w,
                bottom: 30.h,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Icon(Icons.key_rounded, size: 30.sp, color: AppColors.secondaryPurple),
                ),
              ),

              // Sparkles
              Positioned(top: 20.h, left: 40.w, child: Icon(Icons.auto_awesome, size: 14.sp, color: AppColors.primaryOrange.withOpacity(0.6))),
              Positioned(top: 50.h, right: 30.w, child: Icon(Icons.auto_awesome, size: 18.sp, color: AppColors.secondaryPurple.withOpacity(0.6))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaf(double angle, Color color) {
    return Transform.rotate(
      angle: angle * 3.14 / 180,
      child: Container(
        width: 60.w,
        height: 100.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.elliptical(60.w, 100.h)),
        ),
      ),
    );
  }

  Widget _build3DLock() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.secondaryPurple,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: AppColors.secondaryPurple.withOpacity(0.4), blurRadius: 15, offset: const Offset(4, 8)),
        ],
      ),
      child: Icon(Icons.lock_rounded, color: Colors.white, size: 32.sp),
    );
  }
}

class ResetFormCard extends StatelessWidget {
  final TextEditingController? controller;
  const ResetFormCard({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.secondaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.smartphone_rounded, color: AppColors.secondaryPurple, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registered Mobile Number',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      'We\'ll send a password reset link to your number',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Custom Phone Field for this card
          Container(
            height: 56.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      Text('🇮🇳', style: TextStyle(fontSize: 14.sp)),
                      SizedBox(width: 4.w),
                      Text(
                        '+91',
                        style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.black),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp, color: AppColors.greyText),
                    ],
                  ),
                ),
                VerticalDivider(color: AppColors.fieldBorder, indent: 15.h, endIndent: 15.h, width: 1),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter your mobile number',
                      hintStyle: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.greyText.withOpacity(0.5)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
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

