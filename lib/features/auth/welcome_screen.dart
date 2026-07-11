import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/auth/login_screen.dart';
import 'package:chillfi/features/auth/widgets/welcome_widgets.dart';
import 'package:chillfi/features/home/home_dashboard_screen.dart';
import 'package:chillfi/features/onboarding/widgets/onboarding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
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
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // 1. TOP BACKGROUND DECORATIONS
          Positioned(
            top: -50.h,
            left: -60.w,
            child: IgnorePointer(
              child: Container(
                width: 200.r,
                height: 200.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            top: 60.h,
            left: 20.w,
            child: const IgnorePointer(
              child: DottedPattern(rows: 6, cols: 4, color: Colors.black12),
            ),
          ),
          Positioned(
            top: 40.h,
            right: -40.w,
            child: IgnorePointer(
              child: Container(
                width: 180.r,
                height: 180.r,
                decoration: BoxDecoration(
                  color: AppColors.secondaryPurple.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // 2. MAIN CONTENT (Fixed Layout, Non-scrollable)
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 5.h), // Decreased top margin
                    
                    // LOGO SECTION - Center aligned logo only
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.shopping_bag_rounded,
                          size: 60.sp,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),

                    SizedBox(height: 25.h),

                    // WELCOME TITLE
                    Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Welcome to ',
                                style: GoogleFonts.poppins(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                ),
                              ),
                              TextSpan(
                                text: 'CHILLFI',
                                style: GoogleFonts.poppins(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Your one-stop destination for premium electronics, accessories and more.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.greyText,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Decorative Divider
                        Container(
                          width: 35.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 25.h),

                    // FEATURE CARDS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        WelcomeFeatureCard(
                          icon: Icons.verified_rounded,
                          title: '100% Original\nProducts',
                          subtitle: 'Genuine products\nyou can trust',
                          iconColor: AppColors.primaryOrange,
                        ),
                        WelcomeFeatureCard(
                          icon: Icons.local_shipping_rounded,
                          title: 'Fast & Reliable\nDelivery',
                          subtitle: 'Quick delivery to\nyour doorstep',
                          iconColor: AppColors.secondaryPurple,
                        ),
                        WelcomeFeatureCard(
                          icon: Icons.percent_rounded,
                          title: 'Best Deals\nEveryday',
                          subtitle: 'Amazing offers &\nexciting discounts',
                          iconColor: AppColors.primaryOrange,
                        ),
                      ],
                    ),

                    // PRODUCT SHOWCASE - Takes up available space
                    Expanded(
                      child: ProductShowcase(floatingAnimation: _floatingAnimation),
                    ),

                    // ACTION BUTTONS
                    Column(
                      children: [
                        OnboardingCTA(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          text: 'Get Started',
                        ),
                        SizedBox(height: 12.h),
                        WelcomeSecondaryButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          text: 'Login / Signup',
                        ),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeDashboardScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Continue as Guest',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: AppColors.greyText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10.sp,
                                color: AppColors.greyText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 15.h), // Safe bottom margin
                  ],
                ),
              ),
            ),
          ),

          // 3. BOTTOM DECORATIVE WAVE
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SizedBox(
                height: 80.h,
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
}
