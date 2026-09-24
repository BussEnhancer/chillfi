import 'package:chillfi/features/categories/categories_screen.dart';
import 'package:chillfi/features/deals/flash_deals_screen.dart';
import 'package:chillfi/features/offers/offers_products_screen.dart';
import 'package:chillfi/features/product_details/product_details_screen.dart';
import 'package:chillfi/features/product_listing/product_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens an admin-configured link (banners, promo banners, notifications).
/// Accepts website-style paths (`/product/<id>`, `/offers`, `/products?category=<id>`)
/// or full URLs; chillfi.in URLs open in-app, other URLs open externally.
Future<void> openAppLink(BuildContext context, String? link) async {
  final raw = (link ?? '').trim();
  Uri? uri = raw.isEmpty ? null : Uri.tryParse(raw);

  if (uri != null && uri.hasScheme && !uri.host.endsWith('chillfi.in')) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }

  final seg = uri?.pathSegments.where((s) => s.isNotEmpty).toList() ?? const <String>[];
  final q = uri?.queryParameters ?? const <String, String>{};
  final Widget screen;
  if (seg.length >= 2 && seg[0] == 'product') {
    screen = ProductDetailsScreen(productId: seg[1]);
  } else if (seg.isNotEmpty && seg[0] == 'offers') {
    screen = const OffersProductsScreen();
  } else if (seg.isNotEmpty && (seg[0] == 'deals' || seg[0] == 'flash-deals')) {
    screen = const FlashDealsScreen();
  } else if (seg.isNotEmpty && seg[0] == 'categories') {
    screen = const CategoriesScreen();
  } else {
    screen = ProductListingScreen(
      categoryId: q['category'],
      brandId: q['brand'],
      searchQuery: q['q'],
    );
  }
  if (!context.mounted) return;
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}
