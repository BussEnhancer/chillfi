import 'api_service.dart';

class AppRemoteConfig {
  final bool maintenanceMode;
  final String maintenanceMessage;
  final bool forceUpdateEnabled;
  final String minAppVersion;
  final String forceUpdateMessage;

  AppRemoteConfig({
    required this.maintenanceMode,
    required this.maintenanceMessage,
    required this.forceUpdateEnabled,
    required this.minAppVersion,
    required this.forceUpdateMessage,
  });

  factory AppRemoteConfig.fromJson(Map<String, dynamic> json) => AppRemoteConfig(
        maintenanceMode: json['maintenance_mode'] == true,
        maintenanceMessage: json['maintenance_message'] ?? '',
        forceUpdateEnabled: json['force_update_enabled'] == true,
        minAppVersion: json['min_app_version'] ?? '1.0.0',
        forceUpdateMessage: json['force_update_message'] ?? '',
      );
}

class RemoteConfigService {
  final _api = ApiService();

  Future<AppRemoteConfig?> fetch() async {
    try {
      final res = await _api.get('/app-config');
      return AppRemoteConfig.fromJson(res.data['data']);
    } catch (_) {
      return null;
    }
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
