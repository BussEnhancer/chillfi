import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/auth/forgot_password_screen.dart';
import 'package:chillfi/features/auth/otp_verification_screen.dart';
import 'package:chillfi/features/auth/signup_screen.dart';
import 'package:chillfi/features/auth/widgets/login_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
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
              child: CustomPaint(
                painter: HeaderCurvePainter(),
              ),
            ),
          ),

          // Dotted Pattern
          Positioned(
            top: 60.h,
            right: 20.w,
            child: Opacity(
              opacity: 0.1,
              child: const DottedPattern(rows: 8, cols: 5, color: Colors.white),
            ),
          ),

          // 2. SCROLLABLE CONTENT
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
                        // TOP NAVIGATION AREA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 24.sp),
                            ),
                            const LanguageSelector(),
                          ],
                        ),

                        SizedBox(height: 10.h),

                        // LOGO SECTION
                        Image.asset(
                          'assets/images/logo.png',
                          width: 100.w,
                          height: 100.h,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => Icon(Icons.shopping_bag_rounded, size: 80.sp, color: AppColors.primaryOrange),
                        ),
                        Text(
                          'Experience The Trust with CHILLFI',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.greyText,
                            letterSpacing: 0.5,
                          ),
                        ),

                        SizedBox(height: 25.h),

                        // WELCOME TEXT
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Welcome ',
                                style: GoogleFonts.poppins(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Back!',
                                style: GoogleFonts.poppins(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w800,
                                  foreground: Paint()
                                    ..shader = AppColors.purpleGradient.createShader(
                                      const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                                    ),
                                ),
                              ),
                              const TextSpan(
                                text: ' 👋',
                                style: TextStyle(fontSize: 26),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Login to continue shopping amazing deals',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        SizedBox(height: 30.h),

                        // LOGIN CARD
                        Container(
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Login with Mobile Number',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      Text(
                                        'We\'ll send you an OTP to verify',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.sp,
                                          color: AppColors.greyText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              const PremiumPhoneInput(),
                              SizedBox(height: 12.h),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryPurple,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // PRIMARY BUTTON
                        PrimaryGradientButton(
                          text: 'Send OTP',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const OtpVerificationScreen()),
                            );
                          },
                        ),

                        SizedBox(height: 20.h),

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

                        SizedBox(height: 20.h),

                        // WHATSAPP BUTTON
                        WhatsAppButton(onTap: () {}),

                        SizedBox(height: 16.h),

                        // SECURITY INFO
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_user_rounded, color: AppColors.secondaryPurple, size: 14.sp),
                            SizedBox(width: 6.w),
                            Column(
                              children: [
                                Text(
                                  '100% Secure & Private',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
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

                        SizedBox(height: 40.h),

                        // BOTTOM SECTION (Product Showcase + Features)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Soft background wave for showcase
                            Positioned(
                              bottom: -50.h,
                              left: -100.w,
                              right: -100.w,
                              child: Container(
                                height: 300.h,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primaryOrange.withOpacity(0.05),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        children: [
                                          const FeatureItem(
                                            icon: Icons.verified_rounded,
                                            title: '100% Original Products',
                                            subtitle: 'Genuine products you can trust',
                                            iconColor: AppColors.primaryOrange,
                                          ),
                                          SizedBox(height: 20.h),
                                          const FeatureItem(
                                            icon: Icons.local_shipping_rounded,
                                            title: 'Fast & Reliable Delivery',
                                            subtitle: 'Quick delivery to your doorstep',
                                            iconColor: AppColors.secondaryPurple,
                                          ),
                                          SizedBox(height: 20.h),
                                          const FeatureItem(
                                            icon: Icons.percent_rounded,
                                            title: 'Best Deals Everyday',
                                            subtitle: 'Amazing offers & exciting discounts',
                                            iconColor: AppColors.primaryOrange,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 4,
                                      child: ProductComposition(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 40.h),
                                // SIGNUP FOOTER
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'New to CHILLFI? ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: AppColors.greyText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            'Sign Up',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14.sp,
                                              color: AppColors.secondaryPurple,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Icon(Icons.arrow_forward_rounded, color: AppColors.secondaryPurple, size: 16.sp),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30.h),
                              ],
                            ),
                          ],
                        ),
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
