import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/auth/welcome_screen.dart';
import 'package:chillfi/features/onboarding/onboarding_screen_three.dart';
import 'package:chillfi/features/onboarding/widgets/onboarding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreenTwo extends StatefulWidget {
  const OnboardingScreenTwo({super.key});

  @override
  State<OnboardingScreenTwo> createState() => _OnboardingScreenTwoState();
}

class _OnboardingScreenTwoState extends State<OnboardingScreenTwo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<double>(begin: 0, end: -12).animate(
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
            top: 20.h,
            left: -30.w,
            child: Container(
              width: 150.r,
              height: 150.r,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Dotted patterns as per reference
          Positioned(
            top: 100.h,
            left: 20.w,
            child: const DottedPattern(rows: 8, cols: 4, color: Colors.black12),
          ),
          Positioned(
            top: 320.h,
            right: 20.w,
            child: const DottedPattern(rows: 8, cols: 4, color: Colors.black12),
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
                      // Large Orange Radial Glow
                      Container(
                        width: 280.r,
                        height: 280.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryOrange.withOpacity(0.9),
                              AppColors.primaryOrange,
                            ],
                          ),
                        ),
                      ),
                      
                      // White Podium Base
                      Positioned(
                        bottom: 40.h,
                        child: Column(
                          children: [
                            Container(
                              width: 240.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.elliptical(240.w, 50.h)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -25),
                              child: Container(
                                width: 220.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  borderRadius: BorderRadius.all(Radius.elliptical(220.w, 12.h)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tilted Floating Smartphone Mockup
                      AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatingAnimation.value),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001) // perspective
                                ..rotateY(-0.1) // slight tilt
                                ..rotateX(0.05),
                              child: child,
                            ),
                          );
                        },
                        child: const PhoneMockupWithUI(),
                      ),

                      // Floating Feature Cards
                      Positioned(
                        top: 200.h,
                        left: 25.w,
                        child: const FeatureBadge(
                          icon: Icons.smartphone_rounded,
                          title: 'Wide Range\nof Products',
                          iconColor: AppColors.secondaryPurple,
                        ),
                      ),
                      Positioned(
                        top: 100.h,
                        right: 25.w,
                        child: const FeatureBadge(
                          icon: Icons.verified_outlined,
                          title: '100% Original\nProducts',
                          iconColor: AppColors.primaryOrange,
                        ),
                      ),
                      Positioned(
                        bottom: 120.h,
                        right: 20.w,
                        child: const FeatureBadge(
                          icon: Icons.security_rounded,
                          title: 'Secure\nShopping',
                          iconColor: AppColors.secondaryPurple,
                        ),
                      ),

                      // Decorative Orbs
                      Positioned(
                        top: 140.h,
                        left: 60.w,
                        child: _buildOrb(16, AppColors.primaryOrange),
                      ),
                      Positioned(
                        top: 70.h,
                        right: 40.w,
                        child: _buildOrb(20, AppColors.secondaryPurple),
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
                        'Everything You Need,',
                        style: GoogleFonts.poppins(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      PremiumGradientText(
                        text: 'All in One Place',
                        style: GoogleFonts.poppins(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        gradient: AppColors.orangePurpleGradient,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Explore a wide range of top brands and categories. Original products you can trust.',
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
                    _buildIndicator(true),
                    _buildIndicator(false),
                  ],
                ),

                SizedBox(height: 30.h),

                // --- CTA BUTTON ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: OnboardingCTA(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingScreenThree()),
                      );
                    },
                    text: 'Next',
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
            color: color.withOpacity(0.3),
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
