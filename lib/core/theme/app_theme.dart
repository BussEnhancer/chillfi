import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// ChillFi design tokens — derived from the values the existing screens already use most.
/// Use these for new/normalised UI instead of one-off numbers.

/// Spacing scale (logical px, scale with `.w`/`.h` at the call site).
class AppSpace {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal page gutter for regular screens (lists, details, account pages).
  static const double page = 20;

  /// Horizontal page gutter for full-bleed brand screens (auth, success/failure, system screens).
  static const double pageAuth = 24;
}

/// Corner radii. Chips/badges `s`, inputs + small cards `m`, buttons + cards `l`, sheets/dialogs `xl`.
class AppRadius {
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

/// Standard control heights.
class AppSize {
  static const double button = 56;
  static const double buttonSmall = 44;
  static const double input = 56;
  static const double backButton = 40;
  static const double iconBack = 20;
}

/// Motion vocabulary — one duration/curve set used everywhere.
class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration page = Duration(milliseconds: 320);
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  /// Content entrance inside a screen (runs together with the page transition, never after it).
  static const Duration content = Duration(milliseconds: 380);
}

/// Typography roles (Poppins). Sizes are design px — `.sp` applied here.
class AppText {
  static TextStyle display({Color color = AppColors.darkText}) => GoogleFonts.poppins(fontSize: 26.sp, fontWeight: FontWeight.w700, color: color, height: 1.25);
  static TextStyle pageTitle({Color color = AppColors.darkText}) => GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: color);
  static TextStyle pageSubtitle({Color color = AppColors.greyText}) => GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500, color: color);
  static TextStyle sectionTitle({Color color = AppColors.darkText}) => GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: color);
  static TextStyle cardTitle({Color color = AppColors.darkText}) => GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: color);
  static TextStyle body({Color color = AppColors.darkText}) => GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400, color: color, height: 1.45);
  static TextStyle bodySmall({Color color = AppColors.greyText}) => GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w400, color: color, height: 1.4);
  static TextStyle label({Color color = AppColors.darkText}) => GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: color);
  static TextStyle caption({Color color = AppColors.greyText}) => GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w500, color: color);
  static TextStyle button({Color color = Colors.white}) => GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: color);
}

/// Forward navigation: the new screen slides in a short distance from the right while fading in,
/// the old one drifts slightly left. Back is the exact reverse — so moving deeper / returning reads
/// spatially, instead of one static image replacing another.
class ChillFiPageTransitionsBuilder extends PageTransitionsBuilder {
  const ChillFiPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.page;

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 280);

  static final _inOffset = Tween<Offset>(begin: const Offset(0.12, 0), end: Offset.zero);
  static final _outOffset = Tween<Offset>(begin: Offset.zero, end: const Offset(-0.06, 0));

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final inAnim = CurvedAnimation(parent: animation, curve: AppMotion.enter, reverseCurve: AppMotion.exit);
    final outAnim = CurvedAnimation(parent: secondaryAnimation, curve: AppMotion.enter, reverseCurve: AppMotion.exit);
    return SlideTransition(
      position: _outOffset.animate(outAnim),
      child: FadeTransition(
        opacity: inAnim,
        child: SlideTransition(position: _inOffset.animate(inAnim), child: child),
      ),
    );
  }
}

/// Route for switching bottom-nav tabs: a quick cross-fade (no lateral movement — tabs are siblings).
class TabSwitchRoute<T> extends PageRouteBuilder<T> {
  TabSwitchRoute({required Widget page})
      : super(
          pageBuilder: (_, _, _) => page,
          transitionDuration: AppMotion.medium,
          reverseTransitionDuration: AppMotion.fast,
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut), child: child),
        );
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.secondaryPurple,
      primary: AppColors.secondaryPurple,
      secondary: AppColors.primaryOrange,
      surface: Colors.white,
      error: const Color(0xFFE53935),
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: Colors.white);
    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ChillFiPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(), // keeps native edge-swipe back
      }),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.secondaryPurple),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkText,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.m)),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkText),
        contentTextStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.darkText, height: 1.45),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl))),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.secondaryPurple, textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // In-app primary actions are purple; orange gradients are reserved for onboarding/auth CTAs.
          backgroundColor: AppColors.secondaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.l)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryPurple,
          side: const BorderSide(color: AppColors.secondaryPurple, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.l)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      checkboxTheme: CheckboxThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.secondaryPurple,
        selectionHandleColor: AppColors.secondaryPurple,
      ),
    );
  }
}
