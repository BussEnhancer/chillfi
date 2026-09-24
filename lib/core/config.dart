// Pass --dart-define=API_URL=... at build time to override.
// flutter build apk --release (uses defaultValue below)
const String _kApiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://chillfi.in/api', // production domain
);

class AppConfig {
  static const String baseUrl = _kApiUrl;
  static const String appName = 'ChillFi';
  static const String appVersion = '1.0.0';
}
