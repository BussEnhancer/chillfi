import 'package:chillfi/core/widgets/app_empty_state.dart';
import 'package:chillfi/features/auth/login_screen.dart';
import 'package:flutter/material.dart';

/// Shown on account-only screens (orders, wishlist) when nobody is signed in.
class GuestPrompt extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const GuestPrompt({super.key, required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: icon,
      title: title,
      message: message,
      actionLabel: 'Login / Sign up',
      onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
    );
  }
}
