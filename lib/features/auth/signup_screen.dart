import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/features/auth/otp_verification_screen.dart';
import 'package:chillfi/features/auth/widgets/login_widgets.dart';
import 'package:chillfi/features/auth/widgets/otp_widgets.dart';
import 'package:chillfi/features/auth/widgets/signup_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _acceptedTerms = false;
  bool _isLoading = false;
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

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
    _termsTap = TapGestureRecognizer()
      ..onTap = () => _showPolicy('Terms & Conditions',
          'By using ChillFi, you agree to our Terms & Conditions. You must be 18+ to use this app. Orders are subject to availability and our return policy.');
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => _showPolicy('Privacy Policy',
          'We collect only the data needed to process your orders. Your data is encrypted and never sold to third parties. You may request deletion of your data at any time.');
  }

  void _showPolicy(String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _fieldError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<void> _onSignUp() async {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty) return _fieldError('Please enter your full name');
    if (name.length < 2) return _fieldError('Name must be at least 2 characters');
    if (phone.isEmpty) return _fieldError('Please enter your phone number');
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) return _fieldError('Enter a valid 10-digit mobile number');
    if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(email)) {
      return _fieldError('Enter a valid email address');
    }
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms & Conditions'), backgroundColor: Colors.red),
      );
      return;
    }
    final navigator = Navigator.of(context);
    final signupName = _nameController.text.trim();
    final signupEmail = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
    setState(() => _isLoading = true);
    context.read<AuthProvider>().verifyPhoneFirebase(
      phone,
      codeSent: (verificationId, _) {
        try { setState(() => _isLoading = false); } catch (_) {}
        navigator.push(MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: phone,
            verificationId: verificationId,
            isFromForgotPassword: false,
            isFromSignup: true,
            signupName: signupName,
            signupEmail: signupEmail,
          ),
        ));
      },
      onFailed: (error) {
        try { setState(() => _isLoading = false); } catch (_) {}
        if (mounted) AppErrorDialog.show(context, message: error, title: "Couldn't send OTP");
      },
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      resizeToAvoidBottomInset: true,
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

          // Beige Wave Overlay
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
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100)),
                ),
              ),
            ),
          ),

          // Logo in Orange Part (Consistent with Login Screen)
          Positioned(
            top: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: Hero(
                tag: 'logo_signup',
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

          // 3. MAIN CONTENT - SINGLE SCREEN (NON-SCROLLABLE)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // BACK BUTTON
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

                      // HEADER SECTION
                      Flexible(
                        flex: 3,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 140.h), // Space for the logo
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
                                          color: AppColors.secondaryPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Sign up and start exploring amazing deals',
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

                      // FORM SECTION
                      Flexible(
                        flex: 6,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: 327.w,
                              child: Column(
                                children: [
                                  PremiumAuthField(
                                    label: 'Full Name',
                                    hintText: 'Enter your full name',
                                    prefixIcon: Icons.person_outline_rounded,
                                    controller: _nameController,
                                  ),
                                  SizedBox(height: 12.h),
                                  PremiumPhoneInputWrapper(controller: _phoneController),
                                  SizedBox(height: 12.h),
                                  PremiumAuthField(
                                    label: 'Email Address',
                                    hintText: 'Enter your email address',
                                    prefixIcon: Icons.mail_outline_rounded,
                                    isOptional: true,
                                    controller: _emailController,
                                  ),
                                  SizedBox(height: 16.h),
                                  Row(
                                    children: [
                                      CustomCheckbox(onChanged: (val) => setState(() => _acceptedTerms = val)),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            text: 'I agree to the ',
                                            style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                                            children: [
                                              TextSpan(
                                                text: 'Terms & Conditions',
                                                recognizer: _termsTap,
                                                style: GoogleFonts.poppins(color: AppColors.secondaryPurple, fontWeight: FontWeight.w600),
                                              ),
                                              TextSpan(text: ' and ', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText)),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                recognizer: _privacyTap,
                                                style: GoogleFonts.poppins(color: AppColors.secondaryPurple, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // ACTION SECTION
                      Flexible(
                        flex: 4,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 327.w,
                                  child: PrimaryGradientButton(
                                    text: _isLoading ? 'Sending OTP...' : 'Sign Up',
                                    onTap: _isLoading ? () {} : _onSignUp,
                                  ),
                                ),
                                SizedBox(height: 16.h),
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
                                SizedBox(height: 16.h),
                                // FOOTER
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
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
                                        behavior: HitTestBehavior.opaque,
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

class PremiumPhoneInputWrapper extends StatelessWidget {
  final TextEditingController? controller;
  const PremiumPhoneInputWrapper({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              color: AppColors.secondaryPurple.withValues(alpha: 0.08),
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
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter mobile number',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: AppColors.greyText.withValues(alpha: 0.5),
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

