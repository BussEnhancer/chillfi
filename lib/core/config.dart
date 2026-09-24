import 'package:package_info_plus/package_info_plus.dart';
// Pass --dart-define=API_URL=... at build time to override.
// flutter build apk --release (uses defaultValue below)
const String _kApiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://chillfi.in/api', // production domain
);

class AppConfig {
  static const String baseUrl = _kApiUrl;
  static const String appName = 'ChillFi';
  /// Real installed version (from the platform, i.e. pubspec `version:`) — never hardcode it,
  /// otherwise force-update comparisons can lock out up-to-date users.
  static Future<String> installedVersion() async => (await PackageInfo.fromPlatform()).version;
}
