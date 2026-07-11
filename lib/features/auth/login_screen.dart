import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/features/auth/forgot_password_screen.dart';
import 'package:chillfi/features/auth/otp_verification_screen.dart';
import 'package:chillfi/features/auth/signup_screen.dart';
import 'package:chillfi/features/auth/widgets/login_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Background Header Curve
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 220.h,
              child: CustomPaint(
                painter: HeaderCurvePainter(),
              ),
            ),
          ),

          // 2. Dotted Pattern (Top Right)
          Positioned(
            top: 110.h,
            right: 40.w,
            child: Opacity(
              opacity: 0.1,
              child: const DottedPattern(rows: 4, cols: 3, color: Colors.white),
            ),
          ),

          // 3. UI Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar
                    SizedBox(
                      height: 56.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
                            ),
                          ),
                          const LanguageSelector(),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 160.w,
                        height: 80.h,
                        opacity: const AlwaysStoppedAnimation(0.8),
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => Icon(Icons.shopping_bag_rounded, size: 50.sp, color: Colors.grey.withOpacity(0.4)),
                      ),
                    ),

                    const Spacer(flex: 4),

                    // Welcome Text
                    Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Welcome ',
                                style: GoogleFonts.poppins(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E1E1E),
                                ),
                              ),
                              TextSpan(
                                text: 'Back!',
                                style: GoogleFonts.poppins(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryPurple,
                                ),
                              ),
                              const TextSpan(
                                text: ' 👋',
                                style: TextStyle(fontSize: 28),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Login to continue shopping amazing deals',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.greyText.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 4),

                    // Login Card
                    Container(
                      padding: EdgeInsets.all(24.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Card Header Row
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryPurple.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.phone_android_rounded,
                                  color: AppColors.secondaryPurple,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mobile Number',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                    Text(
                                      'OTP will be sent for verification',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: AppColors.greyText.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24.h),

                          PremiumPhoneInput(controller: _phoneController),

                          SizedBox(height: 16.h),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryPurple,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Primary Button
                    PrimaryGradientButton(
                      text: 'Send OTP',
                      onTap: () async {
                        final auth = context.read<AuthProvider>();
                        final phone = _phoneController.text.trim();
                        if (phone.length != 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
                          );
                          return;
                        }
                        auth.setPhone(phone);
                        final sent = await auth.sendOtp(phone, purpose: 'login');
                        if (!mounted) return;
                        if (sent) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtpVerificationScreen(
                                phoneNumber: phone,
                                isFromForgotPassword: false,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(auth.message)),
                          );
                        }
                      },
                    ),

                    const Spacer(flex: 2),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.fieldBorder.withOpacity(0.5))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text('OR', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.greyText.withOpacity(0.4))),
                        ),
                        Expanded(child: Divider(color: AppColors.fieldBorder.withOpacity(0.5))),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // Security Tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_rounded, color: AppColors.secondaryPurple, size: 20.sp),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('100% Secure & Private', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                            Text('Your data is encrypted & safe', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText)),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // Bottom Image Graphic
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png', // Using small logo as placeholder for the graphic in image
                        height: 50.h,
                        opacity: const AlwaysStoppedAnimation(0.2),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('New to CHILLFI? ', style: GoogleFonts.poppins(fontSize: 15.sp, color: AppColors.greyText, fontWeight: FontWeight.w500)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                          child: Row(
                            children: [
                              Text('Sign Up', style: GoogleFonts.poppins(fontSize: 15.sp, color: AppColors.secondaryPurple, fontWeight: FontWeight.w700)),
                              SizedBox(width: 4.w),
                              Icon(Icons.arrow_forward_rounded, color: AppColors.secondaryPurple, size: 18.sp),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
