import 'api_service.dart';

/// Customer-support contact, edited in Admin → Settings → Store Info (served by /app-config).
class StoreContact {
  final String? phone;
  final String? phoneHref;
  final String? whatsappHref;
  final String? email;
  const StoreContact({this.phone, this.phoneHref, this.whatsappHref, this.email});
  static const empty = StoreContact();

  factory StoreContact.fromJson(Map<String, dynamic>? j) => j == null
      ? empty
      : StoreContact(
          phone: j['phone'] as String?,
          phoneHref: j['phone_href'] as String?,
          whatsappHref: j['whatsapp_href'] as String?,
          email: j['email'] as String?,
        );
}

class AppRemoteConfig {
  final bool maintenanceMode;
  final String maintenanceMessage;
  final bool forceUpdateEnabled;
  final String minAppVersion;
  final String forceUpdateMessage;
  final bool freeShippingEnabled;
  final double freeShippingThreshold;

  AppRemoteConfig({
    required this.maintenanceMode,
    required this.maintenanceMessage,
    required this.forceUpdateEnabled,
    required this.minAppVersion,
    required this.forceUpdateMessage,
    this.freeShippingEnabled = true,
    this.freeShippingThreshold = 499,
  });

  factory AppRemoteConfig.fromJson(Map<String, dynamic> json) => AppRemoteConfig(
        maintenanceMode: json['maintenance_mode'] == true,
        maintenanceMessage: json['maintenance_message'] ?? '',
        forceUpdateEnabled: json['force_update_enabled'] == true,
        minAppVersion: json['min_app_version'] ?? '1.0.0',
        forceUpdateMessage: json['force_update_message'] ?? '',
        freeShippingEnabled: json['free_shipping_enabled'] != false,
        freeShippingThreshold: (json['free_shipping_threshold'] as num?)?.toDouble() ?? 499,
      );
}

class RemoteConfigService {
  final _api = ApiService();

  static StoreContact? _contact;

  Future<AppRemoteConfig?> fetch() async {
    try {
      final res = await _api.get('/app-config');
      final data = res.data['data'] as Map<String, dynamic>;
      _contact = StoreContact.fromJson(data['contact'] as Map<String, dynamic>?);
      return AppRemoteConfig.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Latest support contact (fetched with the app config; refreshed if not loaded yet).
  static Future<StoreContact> contact() async {
    if (_contact == null) await RemoteConfigService().fetch();
    return _contact ?? StoreContact.empty;
  }

  /// Returns true if [current] is strictly less than [minimum], comparing
  /// dot-separated numeric segments (e.g. "1.2.0" vs "1.10.0").
  static bool isBelowMinimum(String current, String minimum) {
    final c = current.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final m = minimum.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final len = c.length > m.length ? c.length : m.length;
    for (var i = 0; i < len; i++) {
      final cv = i < c.length ? c[i] : 0;
      final mv = i < m.length ? m[i] : 0;
      if (cv != mv) return cv < mv;
    }
    return false;
  }
}
