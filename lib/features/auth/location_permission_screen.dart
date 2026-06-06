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
                        SizedBox(height: 20.h),

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

                        SizedBox(height: 20.h),

                        // ILLUSTRATION
                        const LocationIllustration(),

                        SizedBox(height: 20.h),

                        // TITLE
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
                                      const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0),
                                    ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            'To show you nearby stores, faster delivery options, and better deals, we need access to your location.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: AppColors.greyText,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ),

                        SizedBox(height: 30.h),

                        // BENEFITS CARD
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryPurple.withOpacity(0.04),
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

                        SizedBox(height: 32.h),

                        // PRIMARY BUTTON
                        PrimaryGradientButton(
                          text: 'Allow Location Access',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationPermissionScreen()),
                            );
                          },
                        ),

                        SizedBox(height: 16.h),

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
                            child: Center(
                              child: Text(
                                'Allow While Using App',
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryPurple,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // NOT NOW
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Not Now',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.greyText,
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // PRIVACY FOOTER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.verified_user_rounded, color: AppColors.secondaryPurple, size: 16.sp),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'We value your privacy. Your location is never shared with anyone and is used only to improve your experience.',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: AppColors.greyText,
                                  height: 1.4,
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
