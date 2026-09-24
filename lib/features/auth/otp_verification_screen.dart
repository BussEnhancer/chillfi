import 'dart:async';

import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/features/auth/location_permission_screen.dart';
import 'package:chillfi/features/auth/reset_password_screen.dart';
import 'package:chillfi/features/auth/widgets/login_widgets.dart';
import 'package:chillfi/features/auth/widgets/otp_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? verificationId;
  final bool isFromForgotPassword;
  final bool isFromSignup;
  final String? signupName;
  final String? signupEmail;
  const OtpVerificationScreen({
    super.key,
    this.phoneNumber = "+91 98765 43210",
    this.verificationId,
    this.isFromForgotPassword = false,
    this.isFromSignup = false,
    this.signupName,
    this.signupEmail,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _enteredOtp = '';
  int _secondsLeft = 60;
  Timer? _countdownTimer;
  String? _verificationId;

  Future<void> _onVerify() async {
    if (_enteredOtp.length != 6) return;
    final auth = context.read<AuthProvider>();

    if (widget.isFromForgotPassword) {
      // Forgot-password stays on old backend OTP flow
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(phone: widget.phoneNumber, otp: _enteredOtp)),
      );
      return;
    }

    // Login & signup both use Firebase phone auth
    final verificationId = _verificationId;
    if (verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please go back and try again.'), backgroundColor: Colors.red),
      );
      return;
    }

    final success = await auth.firebaseVerify(
      verificationId,
      _enteredOtp,
      name: widget.signupName,
      email: widget.signupEmail,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.message), backgroundColor: Colors.red),
      );
    }
  }

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

    _verificationId = widget.verificationId;
    _controller.forward();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _secondsLeft = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timerLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ... (existing background decorations)
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

          // Logo in Orange Part
          Positioned(
            top: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: Hero(
                tag: 'logo_otp',
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 160.w,
                  height: 160.h,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Icon(Icons.shopping_bag_rounded, size: 100.sp, color: AppColors.primaryOrange),
                ),
              ),
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
                      // BACK BUTTON AREA
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

                      // LOGO & HEADER SECTION
                      Flexible(
                        flex: 3,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 80.h), // Space for the positioned logo
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
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // OTP INPUT SECTION
                      Flexible(
                        flex: 4,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryPurple.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(30.r),
                                    border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.1)),
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
                                      SizedBox(width: 8.w),
                                      GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: Icon(Icons.edit_outlined, color: AppColors.secondaryPurple, size: 16.sp),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 32.h),
                                SizedBox(
                                  width: 327.w,
                                  child: OtpInputField(
                                    onCompleted: (otp) {
                                      _enteredOtp = otp;
                                      _onVerify();
                                    },
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                if (_secondsLeft > 0)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'OTP will expire in ',
                                        style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText),
                                      ),
                                      Text(
                                        _timerLabel,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          color: AppColors.primaryOrange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                SizedBox(height: 8.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Didn\'t receive OTP? ',
                                      style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText),
                                    ),
                                    GestureDetector(
                                      onTap: _secondsLeft == 0
                                          ? () {
                                              context.read<AuthProvider>().verifyPhoneFirebase(
                                                widget.phoneNumber,
                                                codeSent: (newVerificationId, resendToken) {
                                                  setState(() => _verificationId = newVerificationId);
                                                  _startCountdown();
                                                },
                                                onFailed: (error) {
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                                                  );
                                                },
                                              );
                                            }
                                          : null,
                                      child: Text(
                                        _secondsLeft == 0 ? 'Resend OTP' : 'Resend in ${_secondsLeft}s',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          color: _secondsLeft == 0 ? AppColors.secondaryPurple : AppColors.greyText,
                                          fontWeight: FontWeight.w700,
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

                      SizedBox(height: 32.h),

                      // SECURITY & ACTIONS SECTION
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
                                  child: const SecurityInfoCard(),
                                ),
                                SizedBox(height: 32.h),
                                SizedBox(
                                  width: 327.w,
                                  child: PrimaryGradientButton(
                                    text: 'Verify & Continue',
                                    onTap: _onVerify,
                                  ),
                                ),
                                SizedBox(height: 40.h), // Bottom buffer
                              ],
                            ),
                          ),
                        ),
                      ),
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

