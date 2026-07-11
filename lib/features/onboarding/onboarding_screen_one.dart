import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/auth/welcome_screen.dart';
import 'package:chillfi/features/onboarding/onboarding_screen_two.dart';
import 'package:chillfi/features/onboarding/widgets/onboarding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreenOne extends StatefulWidget {
  const OnboardingScreenOne({super.key});

  @override
  State<OnboardingScreenOne> createState() => _OnboardingScreenOneState();
}

class _OnboardingScreenOneState extends State<OnboardingScreenOne> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
          // 1. TOP BACKGROUND DECORATIONS
          Positioned(
            top: -40.h,
            left: -40.w,
            child: Container(
              width: 180.r,
              height: 180.r,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 70.h,
            left: 30.w,
            child: const DottedPattern(rows: 6, cols: 5),
          ),

          // 2. TOP SKIP BUTTON
          Positioned(
            top: 55.h,
            right: 24.w,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.greyText,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                  height: 400.h,
                  width: 1.sw,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radial Background Glow behind product
                      Container(
                        width: 260.r,
                        height: 260.r,
                        decoration: const BoxDecoration(
                          gradient: AppColors.productBackgroundGradient,
                          shape: BoxShape.circle,
                        ),
                      ),
                      
                      // Premium White Podium
                      Positioned(
                        bottom: 50.h,
                        child: Container(
                          width: 230.w,
                          height: 45.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.elliptical(230.w, 45.h)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 25,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Floating Product Image (Headphones)
                      AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatingAnimation.value),
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'assets/images/headphone.png', // Assuming asset exists per instructions
                          width: 280.w,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // High-quality fallback if asset is missing
                            return Icon(
                              Icons.headset_rounded,
                              size: 220.sp,
                              color: Colors.white.withValues(alpha: 0.95),
                            );
                          },
                        ),
                      ),

                      // Floating Feature Badges
                      Positioned(
                        top: 110.h,
                        left: 35.w,
                        child: const FeatureBadge(
                          icon: Icons.verified_user_outlined,
                          title: 'Trusted\nQuality',
                          iconColor: AppColors.primaryOrange,
                        ),
                      ),
                      Positioned(
                        top: 40.h,
                        right: 45.w,
                        child: const FeatureBadge(
                          icon: Icons.local_shipping_outlined,
                          title: 'Fast\nDelivery',
                          iconColor: AppColors.secondaryPurple,
                        ),
                      ),
                      Positioned(
                        bottom: 90.h,
                        right: 35.w,
                        child: const FeatureBadge(
                          icon: Icons.percent_rounded,
                          title: 'Best\nDeals',
                          iconColor: AppColors.primaryOrange,
                        ),
                      ),

                      // Decorative Elements (Floating Orbs)
                      Positioned(
                        bottom: 140.h,
                        left: 70.w,
                        child: Container(
                          width: 18.r,
                          height: 18.r,
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 170.h,
                        right: 30.w,
                        child: Container(
                          width: 22.r,
                          height: 22.r,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- TEXT SECTION ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    children: [
                      Text(
                        'Experience',
                        style: GoogleFonts.poppins(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                          letterSpacing: -0.5,
                        ),
                      ),
                      PremiumGradientText(
                        text: 'Premium Shopping',
                        style: GoogleFonts.poppins(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        gradient: AppColors.orangePurpleGradient,
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'Discover the best electronics, accessories and more with unbeatable deals.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.greyText,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
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
                    _buildIndicator(true),
                    _buildIndicator(false),
                    _buildIndicator(false),
                  ],
                ),

                SizedBox(height: 35.h),

                // --- CTA BUTTON ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: OnboardingCTA(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingScreenTwo()),
                      );
                    },
                    text: 'Next',
                  ),
                ),
                
                SizedBox(height: 50.h),
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
