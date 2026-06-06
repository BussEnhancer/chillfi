import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetIllustration extends StatefulWidget {
  const ResetIllustration({super.key});

  @override
  State<ResetIllustration> createState() => _ResetIllustrationState();
}

class _ResetIllustrationState extends State<ResetIllustration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 12).animate(
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
          height: 160.h,
          width: 200.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Decorative Leaves/Background Shapes
              Positioned(
                left: 30.w,
                bottom: 20.h,
                child: _buildDecorativeShape(AppColors.secondaryPurple.withOpacity(0.1)),
              ),
              Positioned(
                right: 30.w,
                bottom: 20.h,
                child: _buildDecorativeShape(AppColors.primaryOrange.withOpacity(0.1)),
              ),

              // Shield
              Transform.translate(
                offset: Offset(0, -_floatAnimation.value),
                child: Container(
                  width: 100.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryPurple,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                      bottomLeft: Radius.circular(50.r),
                      bottomRight: Radius.circular(50.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondaryPurple.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.lock_rounded, color: Colors.white, size: 45.sp),
                  ),
                ),
              ),

              // Password Pill
              Positioned(
                bottom: 20.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(4, (index) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Text('●', style: TextStyle(color: AppColors.greyText.withOpacity(0.5), fontSize: 10.sp)),
                      )),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(color: AppColors.secondaryPurple, shape: BoxShape.circle),
                        child: Icon(Icons.refresh_rounded, color: Colors.white, size: 16.sp),
                      ),
                    ],
                  ),
                ),
              ),

              // Sparkles
              Positioned(top: 20.h, right: 30.w, child: Icon(Icons.star_rounded, size: 14.sp, color: AppColors.primaryOrange.withOpacity(0.6))),
              Positioned(top: 40.h, left: 30.w, child: Icon(Icons.star_rounded, size: 12.sp, color: AppColors.secondaryPurple.withOpacity(0.6))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDecorativeShape(Color color) {
    return Container(
      width: 50.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40.r),
      ),
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ...List.generate(4, (index) => Expanded(
              child: Container(
                height: 4.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: AppColors.secondaryPurple,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            )),
            SizedBox(width: 8.w),
            Text(
              'Strong',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryPurple,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Use 8-16 characters with a mix of letters, numbers & symbols',
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }
}
