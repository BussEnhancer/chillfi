import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/features/auth/otp_verification_screen.dart';
import 'package:chillfi/features/auth/widgets/login_widgets.dart';
import 'package:chillfi/features/auth/widgets/otp_widgets.dart';
import 'package:chillfi/features/auth/widgets/forgot_password_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _phoneController = TextEditingController();

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
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      resizeToAvoidBottomInset: true,
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

          // Logo in Orange Part
          Positioned(
            top: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: Hero(
                tag: 'logo_forgot',
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 140.w,
                  height: 140.h,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Icon(Icons.shopping_bag_rounded, size: 90.sp, color: AppColors.primaryOrange),
                ),
              ),
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
            top: 150.h,
            right: 40.w,
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

          // 3. MAIN CONTENT - SINGLE SCREEN (NON-SCROLLABLE)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // BACK BUTTON & NAVIGATION
                      SizedBox(
                        height: 50.h,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 24.sp),
                            ),
                          ),
                        ),
                      ),

                      // HEADER TEXT SECTION
                      Flexible(
                        flex: 3,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 140.h), // Space for logo
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Forgot ',
                                        style: GoogleFonts.poppins(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Password?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.secondaryPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Don\'t worry! It happens. Enter your registered mobile\nnumber and we\'ll send you reset instructions.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: AppColors.greyText,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // ILLUSTRATION SECTION
                      Flexible(
                        flex: 4,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const ForgotPasswordIllustration(),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // FORM SECTION
                      Flexible(
                        flex: 5,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 327.w,
                                  child: ResetFormCard(controller: _phoneController),
                                ),
                                SizedBox(height: 20.h),
                                SizedBox(
                                  width: 327.w,
                                  child: PrimaryGradientButton(
                                    text: 'Send Reset Link',
                                    onTap: () async {
                                      final phone = _phoneController.text.trim();
                                      if (phone.length != 10) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Enter a valid 10-digit number')),
                                        );
                                        return;
                                      }
                                      final auth = context.read<AuthProvider>();
                                      final navigator = Navigator.of(context);
                                      final messenger = ScaffoldMessenger.of(context);
                                      final sent = await auth.forgotPassword(phone);
                                      if (!mounted) return;
                                      if (sent) {
                                        navigator.push(
                                          MaterialPageRoute(
                                            builder: (_) => OtpVerificationScreen(
                                              phoneNumber: phone,
                                              isFromForgotPassword: true,
                                            ),
                                          ),
                                        );
                                      } else {
                                        messenger.showSnackBar(
                                          SnackBar(content: Text(auth.message)),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // FOOTER SECTION
                      Flexible(
                        flex: 4,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 327.w,
                                  child: Row(
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
                                ),
                                SizedBox(height: 20.h),
                                SizedBox(
                                  width: 327.w,
                                  child: SecondaryOutlinedButton(
                                    text: 'Reset via Email',
                                    icon: Icons.mail_outline_rounded,
                                    onTap: () {
                                      final phone = _phoneController.text.trim();
                                      if (phone.length != 10) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Enter your 10-digit phone number first')),
                                        );
                                        return;
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OtpVerificationScreen(
                                            phoneNumber: phone,
                                            isFromForgotPassword: true,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 25.h),
                                // Enhanced Visibility Security Section
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 10,
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified_user_rounded, color: AppColors.secondaryPurple, size: 18.sp),
                                      SizedBox(width: 10.w),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '100% Secure & Protected',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                          Text(
                                            'Your information is safe with us',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10.sp,
                                              color: AppColors.greyText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ],
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

