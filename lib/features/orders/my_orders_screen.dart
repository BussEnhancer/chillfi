import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/cart_model.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/widgets/guest_prompt.dart';
import 'package:chillfi/features/orders/order_details_screen.dart';
import 'package:chillfi/core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyOrdersScreen extends StatefulWidget {
  /// true when opened from the bottom navigation (shows the nav bar like the other tabs)
  final bool asTab;
  const MyOrdersScreen({super.key, this.asTab = false});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String?> _filters = [null, 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
  final List<String> _labels = ['All', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      context.read<CartProvider>().loadOrders(status: _filters[_tabController.index]);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Processing': return Colors.blue;
      case 'Shipped': return Colors.orange;
      case 'Delivered': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return AppColors.greyText;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text('My Orders', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.darkText)),
            Text('Track and manage orders', style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.secondaryPurple,
          unselectedLabelColor: AppColors.greyText,
          indicatorColor: AppColors.secondaryPurple,
          labelStyle: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600),
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: context.watch<AuthProvider>().user == null
          ? const GuestPrompt(
              icon: Icons.receipt_long_outlined,
              title: 'Sign in to see your orders',
              message: 'Track, cancel and review your orders after you sign in.',
            )
          : Consumer<CartProvider>(builder: (context, cart, _) {
        if (cart.orderState == CartLoadState.loading && cart.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.secondaryPurple));
        }
        if (cart.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 72.sp, color: AppColors.greyText),
                SizedBox(height: 16.h),
                Text(_tabController.index == 0 ? 'No orders yet' : 'No ${_labels[_tabController.index].toLowerCase()} orders',
                    style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                SizedBox(height: 8.h),
                Text(_tabController.index == 0 ? 'Start shopping to see orders here' : 'Orders with this status will appear here',
                    style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => cart.loadOrders(status: _filters[_tabController.index]),
          color: AppColors.secondaryPurple,
          child: ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: cart.orders.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (_, i) {
              final order = cart.orders[i];
              return _OrderCard(
                order: order,
                statusColor: _statusColor(order.status),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: order.id))),
              );
            },
          ),
        );
      }),
      bottomNavigationBar: widget.asTab ? const CustomBottomNavBar(selectedIndex: 2) : null,
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final Color statusColor;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.statusColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderNumber, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                  child: Text(order.status, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text('${order.items.length} item${order.items.length != 1 ? "s" : ""}',
                style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText)),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${order.total.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                Text(
                  '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
