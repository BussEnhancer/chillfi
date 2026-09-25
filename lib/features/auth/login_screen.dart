import 'package:chillfi/features/auth/welcome_screen.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/features/auth/otp_verification_screen.dart';
import 'package:chillfi/features/auth/signup_screen.dart';
import 'package:chillfi/features/auth/widgets/login_widgets.dart';
import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:chillfi/features/auth/widgets/auth_chrome.dart';
import 'package:chillfi/core/theme/app_theme.dart';
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
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.content,
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

          const AuthLogo(),

          // 3. UI Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthBackButton(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
                        }
                      },
                    ),

                    // Same slot as the other auth screens: the shared logo sits here (see AuthLogo)
                    // Title lands on the same line as Signup / OTP (their header block is scaled by FittedBox)
                    SizedBox(height: 95.h),

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
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Back!',
                                style: GoogleFonts.poppins(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.secondaryPurple,
                                ),
                              ),
                              const TextSpan(
                                text: ' 👋',
                                style: TextStyle(fontSize: 22),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Login to continue shopping amazing deals',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.greyText,
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
                            color: Colors.black.withValues(alpha: 0.04),
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
                                  color: AppColors.secondaryPurple.withValues(alpha: 0.1),
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
                                        color: AppColors.greyText.withValues(alpha: 0.7),
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
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Primary Button
                    PrimaryGradientButton(
                      text: _isSending ? 'Sending OTP...' : 'Send OTP',
                      onTap: () {
                        if (_isSending) return;
                        final auth = context.read<AuthProvider>();
                        final phone = _phoneController.text.trim();
                        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
                          );
                          return;
                        }
                        auth.setPhone(phone);
                        final navigator = Navigator.of(context);
                        setState(() => _isSending = true);
                        auth.verifyPhoneFirebase(
                          phone,
                          codeSent: (verificationId, _) {
                            try { setState(() => _isSending = false); } catch (_) {}
                            navigator.push(MaterialPageRoute(
                              builder: (_) => OtpVerificationScreen(
                                phoneNumber: phone,
                                verificationId: verificationId,
                                isFromForgotPassword: false,
                              ),
                            ));
                          },
                          onFailed: (error) {
                            try { setState(() => _isSending = false); } catch (_) {}
                            if (mounted) AppErrorDialog.show(context, message: error, title: "Couldn't send OTP");
                          },
                        );
                      },
                    ),

                    const Spacer(flex: 2),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.fieldBorder.withValues(alpha: 0.5))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text('OR', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.greyText.withValues(alpha: 0.4))),
                        ),
                        Expanded(child: Divider(color: AppColors.fieldBorder.withValues(alpha: 0.5))),
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

                    const Spacer(flex: 5),

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
