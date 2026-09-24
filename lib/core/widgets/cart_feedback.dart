import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Adds a product to the cart and always tells the customer what happened:
/// a short green confirmation on success, the universal error dialog on failure.
Future<bool> addToCartWithFeedback(BuildContext context, String productId, {String? productName, int quantity = 1}) async {
  final cart = context.read<CartProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final err = await cart.addToCart(productId, quantity: quantity);
  if (!context.mounted) return err == null;
  if (err == null) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(productName != null ? '$productName added to cart' : 'Added to cart'),
      backgroundColor: Colors.green.shade600,
      duration: const Duration(seconds: 2),
    ));
    return true;
  }
  await AppErrorDialog.show(context, message: err, title: "Couldn't add to cart");
  return false;
}
