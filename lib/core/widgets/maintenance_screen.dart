import 'package:chillfi/core/services/remote_config_service.dart';
import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:chillfi/core/widgets/maintenance_widgets.dart';
import 'package:chillfi/features/intro/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MaintenanceScreen extends StatefulWidget {
  final String? message;

  const MaintenanceScreen({super.key, this.message});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  bool _checking = false;

  /// Re-reads the live maintenance flag; continues into the app once maintenance is over.
  Future<void> _checkAgain() async {
    if (_checking) return;
    setState(() => _checking = true);
    final config = await RemoteConfigService().fetch();
    if (!mounted) return;
    setState(() => _checking = false);
    if (config == null) {
      AppErrorDialog.show(context, message: AppError.noInternet);
      return;
    }
    if (!config.maintenanceMode) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SplashScreen()));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("We're still working on it. Please check again in a little while."),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    
                    // Brand Section
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/logo_color.png',
                          height: 40.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Shop Smart.",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "Chill More.",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6C2BFF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 60.h),
                    const MaintenanceIllustration(),
                    SizedBox(height: 60.h),

                    Text(
                      "We’re Under Maintenance",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      message ?? "We’re making some improvements to serve you better. We’ll be back soon! 💜",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 40.h),
                    
                    // Thank You Section
                    Column(
                      children: [
                        Icon(Icons.favorite_outline_rounded, color: const Color(0xFF6C2BFF), size: 28.sp),
                        SizedBox(height: 12.h),
                        Text(
                          "Thank you for your patience.\nWe appreciate your support!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 40.h),

                    // Action Button
                    GestureDetector(
                      onTap: _checkAgain,
                      child: Container(
                        width: double.infinity,
                        height: 62.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C2BFF), Color(0xFF8B5CFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C2BFF).withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_checking)
                              SizedBox(width: 22.sp, height: 22.sp, child: const CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                            else
                              Icon(Icons.refresh_rounded, color: Colors.white, size: 22.sp),
                            SizedBox(width: 12.w),
                            Text(
                              _checking ? 'Checking…' : 'Check Again',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 60.h),
                  ],
                ),
              ),
            ),
            const SkylineFooterDecoration(),
          ],
        ),
      ),
    );
  }
}
