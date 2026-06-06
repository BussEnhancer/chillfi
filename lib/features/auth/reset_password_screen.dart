import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/auth/location_permission_screen.dart';
import 'package:chillfi/features/auth/widgets/login_widgets.dart';
import 'package:chillfi/features/auth/widgets/otp_widgets.dart';
import 'package:chillfi/features/auth/widgets/reset_password_widgets.dart';
import 'package:chillfi/features/auth/widgets/signup_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // 1. TOP BACKGROUND
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 200.h,
              child: CustomPaint(painter: HeaderCurvePainter()),
            ),
          ),
          
          // Dotted Pattern
          Positioned(
            top: 50.h,
            right: 20.w,
            child: const Opacity(
              opacity: 0.1,
              child: DottedPattern(rows: 8, cols: 5, color: Colors.white),
            ),
          ),

          // Floating Sphere
          Positioned(
            top: 140.h,
            left: 30.w,
            child: const FloatingSphere(),
          ),

          // 2. BOTTOM WAVE
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 100.h,
              child: CustomPaint(painter: BottomWavePainter()),
            ),
          ),

          // 3. MAIN CONTENT
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // APP BAR AREA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 24.sp),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: AppColors.fieldBorder),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.headset_mic_outlined, size: 16.sp, color: AppColors.secondaryPurple),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Need Help?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10.h),

                        // LOGO
                        Hero(
                          tag: 'logo',
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 80.w,
                            height: 80.h,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Icon(Icons.shopping_bag_rounded, size: 60.sp, color: AppColors.primaryOrange),
                          ),
                        ),
                        Text(
                          'Experience The Trust with CHILLFI',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.greyText,
                          ),
                        ),

                        SizedBox(height: 25.h),

                        // TITLE
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Reset ',
                                style: GoogleFonts.poppins(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Your Password',
                                style: GoogleFonts.poppins(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w800,
                                  foreground: Paint()
                                    ..shader = AppColors.purpleGradient.createShader(
                                      const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0),
                                    ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Create a new password for your account',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // ILLUSTRATION
                        const ResetIllustration(),

                        SizedBox(height: 24.h),

                        // PASSWORD CARD
                        Container(
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
                              const PremiumAuthField(
                                label: 'New Password',
                                hintText: 'Enter new password',
                                prefixIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                              ),
                              SizedBox(height: 12.h),
                              const PasswordStrengthIndicator(),
                              SizedBox(height: 20.h),
                              const PremiumAuthField(
                                label: 'Confirm New Password',
                                hintText: 'Confirm new password',
                                prefixIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // PRIMARY BUTTON
                        PrimaryGradientButton(
                          text: 'Reset Password',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LocationPermissionScreen()),
                            );
                          },
                        ),

                        SizedBox(height: 24.h),

                        // DIVIDER
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.fieldBorder)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'OR',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.greyText,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: AppColors.fieldBorder)),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // SECONDARY BUTTON
                        GestureDetector(
                          onTap: () {},
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
                                Icon(Icons.mail_outline_rounded, color: AppColors.secondaryPurple, size: 20.sp),
                                SizedBox(width: 10.w),
                                Text(
                                  'Reset via Email Link',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondaryPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // SECURITY SECTION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_user_rounded, color: AppColors.secondaryPurple, size: 16.sp),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '100% Secure',
                                  style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
                                ),
                                Text(
                                  'Your information is safe with us',
                                  style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 120.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
