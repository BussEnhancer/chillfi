import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/auth/notification_permission_screen.dart';
import 'package:chillfi/features/auth/widgets/login_widgets.dart';
import 'package:chillfi/features/auth/widgets/otp_widgets.dart';
import 'package:chillfi/features/auth/widgets/permission_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> with SingleTickerProviderStateMixin {
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
            left: 20.w,
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

          // Logo in Orange Part
          Positioned(
            top: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 140.w,
                  height: 140.h,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Icon(Icons.shopping_bag_rounded, size: 90.sp, color: Colors.white),
                ),
              ),
            ),
          ),

          // 3. MAIN CONTENT - NO SCROLLING
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // LOGO & HEADER SECTION
                      Flexible(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 140.h), // Space for the positioned logo
                                const LocationIllustration(),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // TITLE SECTION
                      Flexible(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Allow ',
                                        style: GoogleFonts.poppins(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Location Access',
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
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  child: Text(
                                    'To show you nearby stores, faster delivery options, and better deals, we need access to your location.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: AppColors.greyText,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // BENEFITS CARD
                      Flexible(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              width: 327.w,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondaryPurple.withValues(alpha: 0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const BenefitRow(
                                    icon: Icons.store_rounded,
                                    title: 'Find Nearby Stores',
                                    subtitle: 'Discover stores near you with ease',
                                  ),
                                  const Divider(height: 1, color: AppColors.fieldBorder),
                                  const BenefitRow(
                                    icon: Icons.delivery_dining_rounded,
                                    title: 'Faster Deliveries',
                                    subtitle: 'Get quicker delivery to your exact location',
                                  ),
                                  const Divider(height: 1, color: AppColors.fieldBorder),
                                  const BenefitRow(
                                    icon: Icons.local_offer_rounded,
                                    title: 'Better Deals',
                                    subtitle: 'Receive location-based offers and discounts',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ACTION BUTTONS & FOOTER
                      Flexible(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 12.h),
                                SizedBox(
                                  width: 327.w,
                                  child: PrimaryGradientButton(
                                    text: 'Allow Location Access',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => NotificationPermissionScreen()),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => NotificationPermissionScreen()),
                                    );
                                  },
                                  child: Container(
                                    width: 327.w,
                                    height: 56.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(color: AppColors.secondaryPurple, width: 1.2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Allow While Using App',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondaryPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => NotificationPermissionScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Not Now',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.greyText,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                // PRIVACY FOOTER
                                Container(
                                  width: 327.w,
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
                                      Icon(Icons.verified_user_rounded, color: AppColors.secondaryPurple, size: 16.sp),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          'We value your privacy. Your location is never shared with anyone and is used only to improve your experience.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 9.sp,
                                            color: AppColors.greyText,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),

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
