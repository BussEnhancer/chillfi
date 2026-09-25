import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/cart_model.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/features/cart/apply_coupon_screen.dart';
import 'package:chillfi/features/checkout/checkout_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chillfi/core/widgets/app_back_button.dart';
import 'package:chillfi/core/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
      context.read<CartProvider>().loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cart, _) {
      final isLoading = cart.cartState == CartLoadState.loading && cart.items.isEmpty;

      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 60.w,
          leading: Padding(padding: EdgeInsets.only(left: 16.w), child: const AppBackButton()),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cart', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
              Text('${cart.cartCount} ${cart.cartCount == 1 ? 'Item' : 'Items'}', style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText)),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.secondaryPurple))
            : cart.items.isEmpty
                ? _buildEmptyCart()
                : Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: () => cart.loadCart(),
                        color: AppColors.secondaryPurple,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 160.h),
                          child: Column(
                            children: [
                              // Delivery address
                              _buildAddressSection(cart),
                              SizedBox(height: 12.h),

                              // Cart items
                              ...cart.items.map((item) => _CartItemCard(item: item, cart: cart)),
                              SizedBox(height: 12.h),

                              // Coupon section
                              _buildCouponSection(cart),
                              SizedBox(height: 12.h),

                              // Price summary
                              _buildPriceSummary(cart),
                            ],
                          ),
                        ),
                      ),
                      Align(alignment: Alignment.bottomCenter, child: _buildCheckoutBar(cart)),
                    ],
                  ),
      );
    });
  }

  Widget _buildEmptyCart() {
    return AppEmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Your cart is empty',
      message: 'Add items to get started',
      actionLabel: 'Shop Now',
      onAction: () => Navigator.maybePop(context),
    );
  }


  Widget _buildAddressSection(CartProvider cart) {
    final address = cart.selectedAddress;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: AppColors.secondaryPurple.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.location_on_rounded, color: AppColors.secondaryPurple, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: address == null
                ? GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                    child: Text('Add delivery address', style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.secondaryPurple, fontWeight: FontWeight.w600)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text('Deliver to ${address.name}',
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(color: AppColors.secondaryPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4.r)),
                            child: Text(address.label, style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.secondaryPurple, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      Text(address.fullAddress, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
            child: Text('Change', style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.secondaryPurple, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(CartProvider cart) {
    if (cart.appliedCouponCode != null) {
      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
        child: Row(
          children: [
            Icon(Icons.local_offer_rounded, color: Colors.green, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coupon Applied: ${cart.appliedCouponCode}', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                  Text('You saved ₹${cart.couponDiscount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.green)),
                ],
              ),
            ),
            GestureDetector(
              onTap: cart.removeCoupon,
              child: Icon(Icons.close_rounded, color: AppColors.greyText, size: 20.sp),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplyCouponScreen())),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
        child: Row(
          children: [
            Icon(Icons.local_offer_outlined, color: AppColors.secondaryPurple, size: 20.sp),
            SizedBox(width: 10.w),
            Text('Apply Coupon', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: AppColors.greyText, size: 14.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(CartProvider cart) {
    final s = cart.summary;
    final coupon = cart.couponDiscount;

    // Prices are GST-inclusive: GST is informational (contained in the price, shrinks with a coupon)
    // and is never added — the total is exactly what the order engine charges.
    final adjustedTax = (coupon > 0 && s.subtotal > 0)
        ? s.taxAmount * (s.subtotal - coupon) / s.subtotal
        : s.taxAmount;
    final adjustedTotal = s.subtotal - coupon + s.deliveryFee;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price Details', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
          SizedBox(height: 12.h),
          _priceRow('Price (${s.itemCount} ${s.itemCount == 1 ? 'item' : 'items'})', '₹${(s.subtotal + s.savings).toStringAsFixed(0)}'),
          if (s.savings > 0) _priceRow('Discount', '-₹${s.savings.toStringAsFixed(0)}', valueColor: Colors.green),
          if (coupon > 0) _priceRow('Coupon Discount', '-₹${coupon.toStringAsFixed(0)}', valueColor: Colors.green),
          _priceRow('Delivery Fee', s.deliveryFee == 0 ? 'FREE' : '₹${s.deliveryFee.toStringAsFixed(0)}', valueColor: s.deliveryFee == 0 ? Colors.green : null),
          if (adjustedTax > 0) _priceRow('Includes GST', '₹${adjustedTax.toStringAsFixed(0)}', valueColor: AppColors.greyText),
          Divider(height: 20.h, color: const Color(0xFFEEEEEE)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
              Text('₹${adjustedTotal.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.darkText)),
            ],
          ),
          if (s.savings > 0 || coupon > 0) ...[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8.r)),
              alignment: Alignment.center,
              child: Text(
                'You will save ₹${(s.savings + coupon).toStringAsFixed(0)} on this order',
                style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.green.shade700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText)),
          Text(value, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.darkText)),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(CartProvider cart) {
    final s = cart.summary;
    final coupon = cart.couponDiscount;
    // Same GST-inclusive total as _buildPriceSummary
    final adjustedTotal = s.subtotal - coupon + s.deliveryFee;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5))],
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Amount', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText)),
                Text('₹${adjustedTotal.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.darkText)),
              ],
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                child: Container(
                  height: 54.h,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [BoxShadow(color: AppColors.secondaryPurple.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Checkout', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18.sp),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final CartProvider cart;

  const _CartItemCard({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: item.image != null
                ? CachedNetworkImage(imageUrl: item.image!, width: 80.w, height: 80.h, fit: BoxFit.cover,
                    placeholder: (_, _) => Container(color: const Color(0xFFEEEEEE)),
                    errorWidget: (_, _, _) => Container(color: const Color(0xFFEEEEEE), child: Icon(Icons.image_outlined, size: 30.sp, color: AppColors.greyText)))
                : Container(width: 80.w, height: 80.h, color: const Color(0xFFEEEEEE),
                    child: Icon(Icons.image_outlined, size: 30.sp, color: AppColors.greyText)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.darkText), maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                if (item.brandName != null)
                  Text(item.brandName!, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText)),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text('₹${item.price.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                    if (item.oldPrice != null) ...[
                      SizedBox(width: 6.w),
                      Text('₹${item.oldPrice!.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText, decoration: TextDecoration.lineThrough)),
                    ],
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    // Quantity controls
                    _qtyButton(Icons.remove, () {
                      if (item.quantity > 1) {
                        cart.updateItem(item.id, item.quantity - 1);
                      } else {
                        cart.removeItem(item.id);
                      }
                    }),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Text('${item.quantity}', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                    ),
                    _qtyButton(Icons.add, () {
                      if (item.quantity < item.stock) cart.updateItem(item.id, item.quantity + 1);
                    }),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => cart.removeItem(item.id),
                      child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 28.h,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 16.sp, color: AppColors.darkText),
      ),
    );
  }
}
