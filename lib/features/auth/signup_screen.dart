import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/auth/widgets/login_widgets.dart';
import 'package:chillfi/features/auth/widgets/otp_widgets.dart';
import 'package:chillfi/features/auth/widgets/signup_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.2, 0.8, curve: Curves.easeOut)),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // 1. TOP BACKGROUND DECORATIONS
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 220.h,
              child: CustomPaint(painter: HeaderCurvePainter()),
            ),
          ),
          
          // Beige Wave Overlay (Simplified as Opacity Layer)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                height: 180.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5E6CA),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                  ),
                ),
              ),
            ),
          ),

          // Dotted Pattern
          Positioned(
            top: 50.h,
            right: 15.w,
            child: const Opacity(
              opacity: 0.1,
              child: DottedPattern(rows: 8, cols: 4, color: Colors.white),
            ),
          ),

          // Floating Spheres
          Positioned(
            top: 160.h,
            right: 30.w,
            child: const FloatingSphere(),
          ),
          Positioned(
            bottom: 60.h,
            left: 30.w,
            child: const FloatingSphere(),
          ),

          // 2. BOTTOM WAVE DESIGN
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 100.h,
              child: CustomPaint(painter: BottomWavePainter()),
            ),
          ),

          // 3. MAIN SCROLLABLE CONTENT
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

                        // TITLE SECTION
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Create ',
                                style: GoogleFonts.poppins(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Your Account',
                                style: GoogleFonts.poppins(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w800,
                                  foreground: Paint()
                                    ..shader = const LinearGradient(
                                      colors: [AppColors.primaryOrange, AppColors.secondaryPurple],
                                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Sign up and start exploring amazing deals',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        SizedBox(height: 30.h),

                        // FORM SECTION
                        const PremiumAuthField(
                          label: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        SizedBox(height: 16.h),
                        
                        // Reusing PremiumPhoneInput but customized for signup look
                        const PremiumPhoneInputWrapper(),
                        
                        SizedBox(height: 16.h),
                        const PremiumAuthField(
                          label: 'Email Address',
                          hintText: 'Enter your email address',
                          prefixIcon: Icons.mail_outline_rounded,
                          isOptional: true,
                        ),
                        SizedBox(height: 16.h),
                        const PremiumAuthField(
                          label: 'Password',
                          hintText: 'Create a strong password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),
                        SizedBox(height: 16.h),
                        const PremiumAuthField(
                          label: 'Confirm Password',
                          hintText: 'Confirm your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),

                        SizedBox(height: 20.h),

                        // CHECKBOX SECTION
                        Row(
                          children: [
                            CustomCheckbox(onChanged: (val) {}),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'I agree to the ',
                                  style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                                  children: [
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: GoogleFonts.poppins(color: AppColors.secondaryPurple, fontWeight: FontWeight.w600),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: GoogleFonts.poppins(color: AppColors.secondaryPurple, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // PRIMARY BUTTON
                        PrimaryGradientButton(
                          text: 'Sign Up',
                          onTap: () {},
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

                        // SOCIAL LOGIN BUTTONS
                        Row(
                          children: [
                            SocialLoginButton(
                              icon: const BrandLogoIcon(brand: 'google'),
                              text: 'Continue with\nGoogle',
                              onTap: () {},
                            ),
                            SizedBox(width: 12.w),
                            SocialLoginButton(
                              icon: const BrandLogoIcon(brand: 'facebook'),
                              text: 'Continue with\nFacebook',
                              onTap: () {},
                            ),
                            SizedBox(width: 12.w),
                            SocialLoginButton(
                              icon: const BrandLogoIcon(brand: 'apple'),
                              text: 'Continue with\nApple',
                              onTap: () {},
                            ),
                          ],
                        ),

                        SizedBox(height: 32.h),

                        // FOOTER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: AppColors.greyText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Login',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: AppColors.secondaryPurple,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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

class PremiumPhoneInputWrapper extends StatelessWidget {
  const PremiumPhoneInputWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.phone_iphone_rounded,
              color: AppColors.secondaryPurple,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mobile Number',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text('🇮🇳', style: TextStyle(fontSize: 14.sp)),
                    SizedBox(width: 4.w),
                    Text(
                      '+91',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16.sp, color: AppColors.greyText),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your mobile number',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: AppColors.greyText.withOpacity(0.5),
                          ),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
