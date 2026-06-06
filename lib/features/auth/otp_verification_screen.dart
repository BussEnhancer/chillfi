import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/auth/reset_password_screen.dart';
import 'package:chillfi/features/auth/widgets/login_widgets.dart';
import 'package:chillfi/features/auth/widgets/otp_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpVerificationScreen({super.key, this.phoneNumber = "+91 98765 43210"});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> with SingleTickerProviderStateMixin {
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
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.7, curve: Curves.easeOut)),
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
          // 1. TOP ABSTRACT BACKGROUND
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
            top: 60.h,
            right: 20.w,
            child: const Opacity(
              opacity: 0.1,
              child: DottedPattern(rows: 8, cols: 5, color: Colors.white),
            ),
          ),

          // Floating Sphere
          Positioned(
            top: 130.h,
            left: 40.w,
            child: const FloatingSphere(),
          ),

          // 2. BOTTOM WAVE DESIGN
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 120.h,
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
                        // BACK BUTTON
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 24.sp),
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // LOGO SECTION
                        Hero(
                          tag: 'logo',
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 90.w,
                            height: 90.h,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Icon(Icons.shopping_bag_rounded, size: 70.sp, color: AppColors.primaryOrange),
                          ),
                        ),
                        Text(
                          'Experience The Trust with CHILLFI',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.greyText,
                          ),
                        ),

                        SizedBox(height: 30.h),

                        // TITLE SECTION
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Verify ',
                                style: GoogleFonts.poppins(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Your Number',
                                style: GoogleFonts.poppins(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w800,
                                  foreground: Paint()
                                    ..shader = AppColors.purpleGradient.createShader(
                                      const Rect.fromLTWH(0.0, 0.0, 250.0, 70.0),
                                    ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Enter the 6-digit OTP sent to',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // PHONE NUMBER CARD (Pill style)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryPurple.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(30.r),
                            border: Border.all(color: AppColors.secondaryPurple.withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone_iphone_rounded, color: AppColors.secondaryPurple, size: 16.sp),
                              SizedBox(width: 8.w),
                              Text(
                                widget.phoneNumber,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // OTP INPUT SECTION
                        OtpInputField(
                          onCompleted: (otp) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
                            );
                          },
                        ),

                        SizedBox(height: 24.h),

                        // TIMER SECTION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'OTP will expire in ',
                              style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText),
                            ),
                            Text(
                              '00:58',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8.h),

                        // RESEND SECTION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Didn\'t receive OTP? ',
                              style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Resend OTP',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: AppColors.secondaryPurple,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 40.h),

                        // SECURITY CARD SECTION
                        const SecurityInfoCard(),

                        SizedBox(height: 32.h),

                        // PRIMARY BUTTON
                        PrimaryGradientButton(
                          text: 'Verify & Continue',
                          onTap: () {},
                        ),

                        SizedBox(height: 24.h),

                        // DIVIDER SECTION
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
                        SecondaryOutlinedButton(
                          text: 'Change Mobile Number',
                          icon: Icons.edit_outlined,
                          onTap: () => Navigator.pop(context),
                        ),

                        SizedBox(height: 120.h), // Spacing for bottom waves
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
