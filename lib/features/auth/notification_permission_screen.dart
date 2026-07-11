import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/auth/widgets/login_widgets.dart';
import 'package:chillfi/features/auth/widgets/otp_widgets.dart';
import 'package:chillfi/features/auth/widgets/notification_widgets.dart';
import 'package:chillfi/features/home/home_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends State<NotificationPermissionScreen> with SingleTickerProviderStateMixin {
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. TOP BACKGROUND
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
              opacity: 0.1,
              child: Container(
                height: 180.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5E6CA),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100)),
                ),
              ),
            ),
          ),

          // Floating Sphere
          Positioned(
            top: 140.h,
            right: 30.w,
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
                      // BACK BUTTON & LOGO AREA
                      Flexible(
                        flex: 5,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // BACK BUTTON (Circular with shadow)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 22.sp),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 140.h), // Space for the positioned logo
                                const NotificationIllustration(),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // TITLE & DESCRIPTION
                      Flexible(
                        flex: 2,
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
                                        text: 'Stay Updated,\n',
                                        style: GoogleFonts.poppins(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Never Miss ',
                                        style: GoogleFonts.poppins(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w800,
                                          foreground: Paint()
                                            ..shader = AppColors.purpleGradient.createShader(
                                              const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0),
                                            ),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'a Deal!',
                                        style: GoogleFonts.poppins(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  child: Text(
                                    'Turn on notifications to get the latest updates on deals, offers, orders and more.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: AppColors.greyText,
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
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
                                color: const Color(0xFFFBF9FF),
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
                                  const NotificationBenefitRow(
                                    icon: Icons.local_offer_rounded,
                                    title: 'Exclusive Offers',
                                    subtitle: 'Get notified about new deals and discounts',
                                  ),
                                  const Divider(height: 1, color: AppColors.fieldBorder),
                                  const NotificationBenefitRow(
                                    icon: Icons.shopping_basket_rounded,
                                    title: 'Order Updates',
                                    subtitle: 'Real-time updates on your orders',
                                  ),
                                  const Divider(height: 1, color: AppColors.fieldBorder),
                                  const NotificationBenefitRow(
                                    icon: Icons.campaign_rounded,
                                    title: 'Important Alerts',
                                    subtitle: 'Receive important announcements & alerts',
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
                                    text: 'Allow Notifications',
                                    onTap: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => HomeDashboardScreen()),
                                        (route) => false,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => HomeDashboardScreen()),
                                      (route) => false,
                                    );
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: 327.w,
                                    height: 56.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(color: AppColors.secondaryPurple, width: 1.2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.notifications_off_outlined, color: AppColors.secondaryPurple, size: 20.sp),
                                        SizedBox(width: 10.w),
                                        Text(
                                          'Not Now',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.secondaryPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                // PRIVACY FOOTER
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.security_rounded, color: AppColors.secondaryPurple, size: 16.sp),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'We respect your privacy.',
                                          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'You can change this anytime in Settings.',
                                      style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                                    ),
                                  ],
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
