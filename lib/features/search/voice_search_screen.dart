import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/services/api_service.dart';
import 'package:chillfi/features/onboarding/widgets/onboarding_widgets.dart';
import 'package:chillfi/features/search/widgets/help_banner_widget.dart';
import 'package:chillfi/features/search/widgets/security_info_card.dart';
import 'package:chillfi/features/search/widgets/voice_mic_button.dart';
import 'package:chillfi/features/search/widgets/voice_wave_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceSearchScreen extends StatefulWidget {
  const VoiceSearchScreen({super.key});

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen> {
  List<String> _trendingNames = [];

  static const List<Map<String, dynamic>> _fallbackChips = [
    {"label": "iphone 15", "icon": Icons.smartphone},
    {"label": "gaming laptop", "icon": Icons.laptop_mac},
    {"label": "boat headphones", "icon": Icons.headphones},
    {"label": "samsung s24", "icon": Icons.phone_android},
    {"label": "smart watch", "icon": Icons.watch},
    {"label": "bluetooth speaker", "icon": Icons.speaker},
    {"label": "canon camera", "icon": Icons.camera_alt},
    {"label": "phone charger", "icon": Icons.power},
    {"label": "macbook air", "icon": Icons.laptop_chromebook},
    {"label": "best offers", "icon": Icons.local_offer},
  ];

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  Future<void> _loadTrending() async {
    try {
      final res = await ApiService().get('/products/trending', params: {'limit': '10'});
      final products = (res.data['data']?['products'] as List?) ?? [];
      if (products.isNotEmpty && mounted) {
        setState(() {
          _trendingNames = products.map((p) => (p['name'] as String? ?? '').toLowerCase()).where((n) => n.isNotEmpty).toList();
        });
      }
    } catch (_) {}
  }

  void _onVoiceResult(String query) {
    if (query.isNotEmpty) Navigator.pop(context, query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative Wave Background
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: Size(200.w, 150.h),
              painter: TopRightWavePainter(),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),

                        // Logo & Tagline
                        Image.asset(
                          'assets/images/logo.png',
                          height: 60.h,
                          errorBuilder: (context, error, stackTrace) => Column(
                            children: [
                              Icon(Icons.shopping_bag_rounded, size: 40.sp, color: AppColors.primaryOrange),
                              Text(
                                "CHILLFI",
                                style: GoogleFonts.poppins(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Experience The Trust with CHILLFI",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.greyText,
                          ),
                        ),

                        SizedBox(height: 40.h),

                        // Main Heading
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                            children: [
                              const TextSpan(text: "Search "),
                              WidgetSpan(
                                child: PremiumGradientText(
                                  text: "with your voice",
                                  style: GoogleFonts.poppins(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  gradient: AppColors.purpleGradient,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Speak clearly to find exactly what you need",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.greyText,
                          ),
                        ),

                        SizedBox(height: 60.h),

                        // Voice Animation Area
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const VoiceWaveWidget(),
                            SizedBox(width: 30.w),
                            VoiceMicButton(onResult: _onVoiceResult),
                            SizedBox(width: 30.w),
                            const VoiceWaveWidget(),
                          ],
                        ),

                        SizedBox(height: 40.h),

                        // Security Card
                        const SecurityInfoCard(),

                        SizedBox(height: 40.h),

                        // Popular Searches Grid
                        _buildPopularSearches(),

                        SizedBox(height: 30.h),

                        // Help Banner
                        const HelpBannerWidget(),

                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Sphere Decoration
          Positioned(
            top: 180.h,
            right: 30.w,
            child: Container(
              width: 24.r,
              height: 24.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF8B44FF), Color(0xFF5D15D4)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_rounded, size: 22.sp, color: AppColors.darkText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSearches() {
    final List<Map<String, dynamic>> items = _trendingNames.isNotEmpty
        ? _trendingNames.map((name) => {"label": name, "icon": Icons.trending_up_rounded} as Map<String, dynamic>).toList()
        : _fallbackChips;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Popular Searches",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "View All",
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryPurple,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Navigator.pop(context, items[index]['label'] as String),
              child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(items[index]['icon'], size: 18.sp, color: AppColors.secondaryPurple.withValues(alpha: 0.6)),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      items[index]['label'],
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        ),
      ],
    );
  }
}

class TopRightWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primaryOrange, Color(0xFFFF8E5E)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(0, 0);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.4, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.6, size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
