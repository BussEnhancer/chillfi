import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared chrome for the auth flow (Login → Signup → OTP → Notifications, Reset password).
/// Every auth screen places the logo and back button in exactly the same spot, and the logo is a
/// shared Hero — so it stays anchored while the rest of the screen transitions around it.

const authLogoHeroTag = 'chillfi_auth_logo';

/// Logo in the orange header. Use as a direct child of the screen's root Stack.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  static const double size = 140;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40.h,
      left: 0,
      right: 0,
      child: Center(
        child: Hero(
          tag: authLogoHeroTag,
          child: Image.asset(
            'assets/images/logo.png',
            width: size.w,
            height: size.h,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => Icon(Icons.shopping_bag_rounded, size: 80.sp, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Back button row used at the top of every auth screen (50 high, left aligned, 44px touch target).
class AuthBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AuthBackButton({super.key, this.onTap});

  static const double barHeight = 50;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: barHeight.h,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          button: true,
          label: 'Back',
          child: GestureDetector(
            onTap: onTap ?? () => Navigator.maybePop(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
              child: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 22.sp),
            ),
          ),
        ),
      ),
    );
  }
}
