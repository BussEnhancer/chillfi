import 'package:flutter/services.dart';

/// Same rules as the backend (addressController.validateAddress). Returns the first problem or null.
String? validateAddressFields({
  required String name,
  required String phone,
  required String line1,
  required String city,
  required String state,
  required String pincode,
}) {
  if (name.trim().length < 2) return 'Please enter the full name (at least 2 characters).';
  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone.trim())) return 'Please enter a valid 10-digit mobile number.';
  if (line1.trim().length < 3) return 'Please enter the house / street address.';
  if (city.trim().isEmpty) return 'Please enter the city.';
  if (state.trim().isEmpty) return 'Please enter the state.';
  if (!RegExp(r'^[1-9]\d{5}$').hasMatch(pincode.trim())) return 'Please enter a valid 6-digit pincode.';
  return null;
}

final phoneInputFormatters = <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)];
final pincodeInputFormatters = <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)];
