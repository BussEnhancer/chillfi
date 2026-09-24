import 'dart:io';

import 'package:chillfi/core/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Converts any error into a message that is safe and useful for customers.
/// Technical details (Dio/HTTP/SQL/stack text) never reach the UI.
class AppError {
  static const noInternet = "You're offline or our server can't be reached. Please check your connection and try again.";
  static const timeout = 'This is taking longer than usual. Please check your connection and try again.';
  static const server = 'Something went wrong on our side. Please try again in a moment.';
  static const session = 'Your session has expired. Please log in again.';
  static const generic = 'Something went wrong. Please try again.';

  static String message(Object? error, {String? fallback}) {
    if (error is DioException) return fromDio(error, fallback: fallback);
    if (error is SocketException) return noInternet;
    if (error is String && isUserFacing(error)) return error;
    return fallback ?? generic;
  }

  static String fromDio(DioException e, {String? fallback}) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return timeout;
      case DioExceptionType.connectionError:
        return noInternet;
      case DioExceptionType.unknown:
        if (e.error is SocketException) return noInternet;
        break;
      default:
        break;
    }
    final status = e.response?.statusCode ?? 0;
    final data = e.response?.data;
    final serverMsg = data is Map ? data['message']?.toString() : null;
    if (status == 401) return session;
    if (status >= 500) return server; // backend already sends a friendly text; never show raw 5xx
    if (serverMsg != null && isUserFacing(serverMsg)) return serverMsg;
    return fallback ?? generic;
  }

  /// Heuristic guard: reject anything that looks technical.
  static bool isUserFacing(String m) {
    final t = m.trim();
    if (t.isEmpty || t.length > 180) return false;
    const technical = ['exception', 'error:', 'stack', 'dio', 'socket', 'sql', 'syntax', 'null check', 'status code', 'undefined', 'typeerror', '<html', 'econn', 'failed host lookup'];
    final lower = t.toLowerCase();
    return !technical.any(lower.contains);
  }
}

/// The single, consistent error dialog used across the app.
class AppErrorDialog {
  static Future<void> show(
    BuildContext context, {
    Object? error,
    String? message,
    String title = 'Something went wrong',
    VoidCallback? onRetry,
  }) {
    final text = message != null && AppError.isUserFacing(message) ? message : AppError.message(error, fallback: message);
    final offline = text == AppError.noInternet;
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(color: const Color(0xFFFFEEE6), shape: BoxShape.circle),
                child: Icon(offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded, color: const Color(0xFFFF6B2C), size: 30.sp),
              ),
              SizedBox(height: 14.h),
              Text(offline ? 'No internet connection' : title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
              SizedBox(height: 8.h),
              Text(text, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText, height: 1.4)),
              SizedBox(height: 20.h),
              Row(
                children: [
                  if (onRetry != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text('Close', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.darkText)),
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onRetry?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(onRetry != null ? 'Try again' : 'OK', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
