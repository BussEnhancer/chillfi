import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/auth/welcome_screen.dart';
import 'package:chillfi/features/onboarding/widgets/onboarding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreenThree extends StatefulWidget {
  const OnboardingScreenThree({super.key});

  @override
  State<OnboardingScreenThree> createState() => _OnboardingScreenThreeState();
}

class _OnboardingScreenThreeState extends State<OnboardingScreenThree> with TickerProviderStateMixin {
  late AnimationController _phoneController;
  late AnimationController _boxController;
  late Animation<double> _phoneFloating;
  late Animation<double> _boxFloating;

  @override
  void initState() {
    super.initState();
    _phoneController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _boxController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _phoneFloating = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _phoneController, curve: Curves.easeInOut),
    );

    _boxFloating = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _boxController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _boxController.dispose();
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
            top: 20.h,
            left: -30.w,
            child: Container(
              width: 150.r,
              height: 150.r,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Positioned(
            top: 100.h,
            left: 20.w,
            child: const DottedPattern(rows: 8, cols: 4, color: Colors.black12),
          ),

          // 2. TOP SKIP BUTTON
          Positioned(
            top: 55.h,
            right: 24.w,
            child: TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('has_seen_onboarding', true);
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.greyText,
              ),
              child: Row(
                children: [
                  Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(Icons.chevron_right_rounded, size: 20.sp),
                ],
              ),
            ),
          ),

          // 3. MAIN CONTENT
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 10.h),
                
                // --- HERO SECTION ---
                SizedBox(
                  height: 420.h,
                  width: 1.sw,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Orange Radial Glow
                      Container(
                        width: 280.r,
                        height: 280.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryOrange.withValues(alpha: 0.9),
                              AppColors.primaryOrange,
                            ],
                          ),
                        ),
                      ),
                      
                      // White Podium Base
                      Positioned(
                        bottom: 40.h,
                        child: Container(
                          width: 240.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.elliptical(240.w, 50.h)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tilted Floating Smartphone with Tracking UI
                      AnimatedBuilder(
                        animation: _phoneFloating,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _phoneFloating.value),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(-0.1)
                                ..rotateX(0.05),
                              child: child,
                            ),
                          );
                        },
                        child: const OrderTrackingMockUI(),
                      ),

                      // Floating Delivery Box
                      Positioned(
                        bottom: 80.h,
                        left: 30.w,
                        child: AnimatedBuilder(
                          animation: _boxFloating,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _boxFloating.value),
                              child: child,
                            );
                          },
                          child: const DeliveryBoxWidget(),
                        ),
                      ),

                      // Floating Feature Cards
                      Positioned(
                        top: 150.h,
                        left: 20.w,
                        child: const FeatureBadge(
                          icon: Icons.local_shipping_outlined,
                          title: 'Fast & Reliable\nDelivery',
                          iconColor: AppColors.secondaryPurple,
                        ),
                      ),
                      Positioned(
                        top: 80.h,
                        right: 20.w,
                        child: const FeatureBadge(
                          icon: Icons.notifications_active_outlined,
                          title: 'Real-time Order\nUpdates',
                          iconColor: AppColors.primaryOrange,
                        ),
                      ),
                      Positioned(
                        bottom: 120.h,
                        right: 15.w,
                        child: const FeatureBadge(
                          icon: Icons.headset_mic_outlined,
                          title: 'Daily Customer\nSupport',
                          iconColor: AppColors.secondaryPurple,
                        ),
                      ),

                      // Decorative Orbs
                      Positioned(
                        top: 250.h,
                        left: 15.w,
                        child: _buildOrb(18, AppColors.secondaryPurple),
                      ),
                      Positioned(
                        top: 220.h,
                        right: 35.w,
                        child: _buildOrb(22, AppColors.primaryOrange),
                      ),
                    ],
                  ),
                ),

                // --- TEXT SECTION ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Track Your Orders,',
                        style: GoogleFonts.poppins(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      PremiumGradientText(
                        text: 'Stay Updated',
                        style: GoogleFonts.poppins(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        gradient: AppColors.orangePurpleGradient,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Real-time tracking, secure payments and daily customer support — we’ve got you covered.',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.greyText,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // --- INDICATORS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIndicator(false),
                    _buildIndicator(false),
                    _buildIndicator(true),
                  ],
                ),

                SizedBox(height: 30.h),

                // --- CTA BUTTON ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: OnboardingCTA(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('has_seen_onboarding', true);
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      );
                    },
                    text: 'Get Started',
                  ),
                ),
                
                SizedBox(height: 40.h),
              ],
            ),
          ),

          // 4. BOTTOM DECORATIVE WAVE
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SizedBox(
                height: 110.h,
                child: CustomPaint(
                  painter: BottomWavePainter(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 6.h,
      width: isActive ? 28.w : 10.w,
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondaryPurple : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
