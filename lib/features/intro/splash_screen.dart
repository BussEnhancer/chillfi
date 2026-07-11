import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/config.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/core/services/remote_config_service.dart';
import 'package:chillfi/core/widgets/force_update_screen.dart';
import 'package:chillfi/core/widgets/maintenance_screen.dart';
import 'package:chillfi/features/home/home_dashboard_screen.dart';
import 'package:chillfi/features/onboarding/onboarding_screen_one.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    final configFuture = RemoteConfigService().fetch();
    final authFuture = context.read<AuthProvider>().checkAuth();
    await Future.delayed(const Duration(seconds: 3));
    final config = await configFuture;
    await authFuture;
    if (!mounted) return;

    if (config != null && config.maintenanceMode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MaintenanceScreen(message: config.maintenanceMessage)),
      );
      return;
    }

    if (config != null &&
        config.forceUpdateEnabled &&
        RemoteConfigService.isBelowMinimum(AppConfig.appVersion, config.minAppVersion)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ForceUpdateScreen(message: config.forceUpdateMessage)),
      );
      return;
    }

    final isLoggedIn = context.read<AuthProvider>().isAuthenticated;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLoggedIn ? const HomeDashboardScreen() : const OnboardingScreenOne(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. TOP ORANGE SECTION (The primary background)
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),
          
          // The Orange Background with Bottom Wave
          ClipPath(
            clipper: OrangeBottomClipper(),
            child: Container(
              height: 0.72.sh,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFF824D),
                    AppColors.primaryOrange,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Dotted Pattern Top Right
                  Positioned(
                    top: 60.h,
                    right: 30.w,
                    child: _buildDottedPattern(5, 5),
                  ),
                  // Dotted Pattern Mid Left
                  Positioned(
                    top: 220.h,
                    left: 20.w,
                    child: _buildDottedPattern(4, 3),
                  ),
                  // Center Branding
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Optimized Logo Size for all screens
                        Image.asset(
                          'assets/images/logo.png',
                          width: 280.w,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. PURPLE WAVE BAND
          CustomPaint(
            size: Size(1.sw, 0.75.sh),
            painter: PurpleWavePainter(),
          ),

          // 3. BOTTOM CONTENT SECTION
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 0.28.sh,
              width: 1.sw,
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  // Features Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFeature(
                          icon: Icons.shield_outlined,
                          label: 'Trusted Quality',
                          iconColor: AppColors.primaryOrange,
                        ),
                        _buildDivider(),
                        _buildFeature(
                          icon: Icons.local_shipping_outlined,
                          label: 'Fast Delivery',
                          iconColor: AppColors.secondaryPurple,
                        ),
                        _buildDivider(),
                        _buildFeature(
                          icon: Icons.workspace_premium_outlined,
                          label: 'Best Deals',
                          iconColor: AppColors.primaryOrange,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIndicator(true),
                      _buildIndicator(false),
                      _buildIndicator(false),
                    ],
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature({required IconData icon, required String label, required Color iconColor}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 36.sp),
          SizedBox(height: 8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40.h,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 5.h,
      width: isActive ? 28.w : 10.w,
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondaryPurple : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildDottedPattern(int rows, int cols) {
    return Opacity(
      opacity: 0.15,
      child: Column(
        children: List.generate(
          rows,
          (i) => Row(
            children: List.generate(
              cols,
              (j) => Container(
                margin: EdgeInsets.all(3.r),
                width: 3.5.r,
                height: 3.5.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrangeBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60.h);
    
    var controlPoint1 = Offset(size.width * 0.25, size.height - 100.h);
    var endPoint1 = Offset(size.width * 0.5, size.height - 50.h);
    
    var controlPoint2 = Offset(size.width * 0.75, size.height + 0.h);
    var endPoint2 = Offset(size.width, size.height - 60.h);

    path.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, endPoint1.dx, endPoint1.dy);
    path.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, endPoint2.dx, endPoint2.dy);
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PurpleWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.secondaryPurple
      ..style = PaintingStyle.fill;

    Path path = Path();
    // Start slightly below the orange wave
    double yStart = size.height - 45.h;
    path.moveTo(0, yStart);

    var controlPoint1 = Offset(size.width * 0.25, yStart - 40.h);
    var endPoint1 = Offset(size.width * 0.5, yStart + 10.h);
    
    var controlPoint2 = Offset(size.width * 0.75, yStart + 60.h);
    var endPoint2 = Offset(size.width, yStart);

    path.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, endPoint1.dx, endPoint1.dy);
    path.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, endPoint2.dx, endPoint2.dy);
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
