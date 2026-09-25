import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/services/api_service.dart';
import 'package:chillfi/features/orders/order_failed_screen.dart';
import 'package:chillfi/features/orders/order_success_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PhonePePaymentScreen extends StatefulWidget {
  final String orderId;
  final String paymentUrl;

  const PhonePePaymentScreen({super.key, required this.orderId, required this.paymentUrl});

  @override
  State<PhonePePaymentScreen> createState() => _PhonePePaymentScreenState();
}

class _PhonePePaymentScreenState extends State<PhonePePaymentScreen> with WidgetsBindingObserver {
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _launchPayment();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_verifying) {
      _verifyPayment();
    }
  }

  Future<void> _launchPayment() async {
    final uri = Uri.tryParse(widget.paymentUrl);
    var opened = false;
    if (uri != null) {
      try {
        // Launch directly: canLaunchUrl() is unreliable under Android 11+ package visibility.
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened && mounted) {
      AppErrorDialog.show(
        context,
        title: "Couldn't open PhonePe",
        message: "We couldn't open the payment page. Please check your connection and try again.",
        onRetry: _launchPayment,
      );
    }
  }

  Future<void> _verifyPayment() async {
    setState(() => _verifying = true);
    try {
      final api = ApiService();
      final res = await api.post('/payment/verify', data: {'order_id': widget.orderId});
      if (!mounted) return;
      final statusVal = res.data['data']?['status'];
      final success = statusVal == 'SUCCESS' || statusVal == 'Paid';
      if (success) {
        final cart = context.read<CartProvider>();
        await cart.loadOrder(widget.orderId);
        final order = cart.currentOrder;
        if (order != null && mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)), (r) => r.isFirst);
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderFailedScreen(reason: 'Payment was not completed.')));
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => OrderFailedScreen(reason: e.response?.data?['message'] ?? 'Payment verification failed.')));
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded, color: AppColors.darkText, size: 22.sp),
        ),
        title: Text('PhonePe Payment', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(color: const Color(0xFFF5EAFF), shape: BoxShape.circle),
                child: Icon(Icons.payment_rounded, color: AppColors.secondaryPurple, size: 48.sp),
              ),
              SizedBox(height: 28.h),

              if (_verifying) ...[
                const CircularProgressIndicator(color: AppColors.secondaryPurple),
                SizedBox(height: 16.h),
                Text('Verifying payment...', style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.greyText)),
              ] else ...[
                Text('Complete Payment', style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                SizedBox(height: 8.h),
                Text('We\'ve opened PhonePe for payment.\nReturn to this screen after completing payment.',
                    style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText), textAlign: TextAlign.center),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _verifyPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text('I\'ve Completed Payment', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: _launchPayment,
                  child: Text('Reopen PhonePe', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.secondaryPurple)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
